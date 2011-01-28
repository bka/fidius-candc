require 'drb'
require 'pp'

# FIDIUS Intrusion Detection with Intelligent User Support.
module FIDIUS
  # options hash from config/msf.yml
  MSF_SETTINGS = YAML.load_file(File.join RAILS_ROOT, 'config', 'msf.yml')
  
  # options hash from config/database.yml (the current RAILS_ENV, in particular)
  DB_SETTINGS = YAML.load_file(File.join RAILS_ROOT, 'config', 'database.yml')[RAILS_ENV]

  # This code is a mess...
  class Boot
    def initialize
      require "fidius/msf_worker/commands"

      raise ArgumentError, "could not load config/msf.yml" unless MSF_SETTINGS
      raise ArgumentError, "could not load config/database.yml" unless DB_SETTINGS

      $:.unshift(File.join MSF_SETTINGS['msf_path'], 'lib')
      require MSF_SETTINGS["subnet_manager_path"]
      require 'msf/base'
      require 'msf/ui/console/driver'
      require 'msf/ui/web'
      require 'fidius/session/msf_session_event'

      require 'fidius/msf_worker/auxillaries/prelude_event_fetcher'
      require 'fidius/msf_worker/auxillaries/tcpdump_wrapper'
      require 'log_matches_helper' # app/helpers

      drb_url = FIDIUS::MSF_SETTINGS['drb_url']
      raise ArgumentError, 'No `drb_url\' in config/msf.yml specified.' unless drb_url

      worker = FIDIUS::MsfWorker.new
      worker.load_commands
      DRb.start_service drb_url, worker
      worker.start

      DRb.thread.join
      worker.puts 'Exiting.'
    end
  end

  class MsfWorker
    PID_FILE = File.join RAILS_ROOT, 'tmp', 'pids', 'msf-worker'

    attr_reader :status

    # Pretty-prints the given objects.
    # @param [Object] obj  Anything.
    # @return [void]
    def p *obj
      pp *obj
    end

    # Overrides +Kernel.puts+ to do two things:
    #
    # 1. prefix the output with the current timestamp (using +$stdout.puts+)
    # 2. log the output into the database
    #
    # In future, this method may be replaced with a "real" log4r
    # instance or something similar. The database logging feature might
    # also be disabled.
    #
    # @param [Object] obj  Anything.
    # @return [void]
    def puts *obj
      WorkerLog.establish_connection DB_SETTINGS unless WorkerLog.connected?
      obj.each do |o|
        WorkerLog.create :message => o
      end
      if ob = obj.shift
        $stdout.puts "[#{Time.now.strftime '%Y-%m-%d %H:%M:%S'}] FIDIUS MSF worker: #{ob}"
        obj.each {|o| $stdout.puts "\t#{o}" } if obj.size > 0
      end
    end

    def initialize
      @status = 'initializing'
      puts "Generated new worker object and registering commands."
    end

    def start
      @status = 'starting'
      puts "Starting. Will listen on #{DRb.uri}..."
      File.open(PID_FILE, 'w') do |f|
        f.puts Process.pid
      end

      puts "Initializing MSF..."
      @framework =  Msf::Simple::Framework.create
      puts "Initialized MSF."

      connect_db
      begin
        @framework.db.exploited_hosts.each do |h|
          h.delete
        end
      rescue ::Exception
        puts "An error occurred while deleting exploited hosts."
        raise
      end

      @console = Msf::Ui::Web::WebConsole.new(@framework,1)

      handler = FIDIUS::Session::MsfSessionEvent.new
      @framework.events.add_session_subscriber(handler)
      @prelude_fetcher = FIDIUS::MsfWorker::Auxillaries::PreludeEventFetcher.new
      load_plugins

      puts "Starting tcp reverse handler"
      run_exploit "exploit/multi/handler", {'LHOST' => '0.0.0.0', 'LPORT' => '5555', 'payload' => 'windows/meterpreter/reverse_tcp'}, true

      # init TcpDumper
#      if MSF_SETTINGS["match_prelude_logs"] == "true"
#        @tcpdump = FIDIUS::TcpDumpWrapper.new MSF_SETTINGS["tcpdump_iface"]
#        @tcpdump.deactivate if MSF_SETTINGS["match_prelude_logs"] == "false" # XXX: ???
#      end
      puts "Started."
      @status = 'running'
    end

    def stop
      @status = 'stopping'
#      @tcpdump.stop

      puts "Halting..."
      @framework.sessions.each_pair do |i,session|
        puts "Killing session #{i}: #{session}"
        session.kill
      end
      disconnect_db
      File.delete PID_FILE if File.exist? PID_FILE
      DRb.stop_service
      puts "Halted."
    end

    def cmd_send_to_terminal cmd
      @console.execute(cmd)
      result = @console.read+@console.prompt
      return result
    end

    def cmd_send_to_msfsession cmd, session_uuid
      input = Rex::Ui::Text::Input::Readline.new
      output = Rex::Ui::Text::Output::Buffer.new
      
      session = get_session_by_uuid @framework.sessions, session_uuid
      session.init_ui(input,output)
      session.run_cmd(cmd)
      return session.console.output.dump_buffer
    end

    def task_created
      Msf::DBManager::Task.find_new_tasks.each do |task|
        begin
          task.progress = 0
          task.save
          if MSF_SETTINGS["match_prelude_logs"] == "true"
            Msf::Plugin::FidiusLogger.on_log do |caused_by, data, socket|
              my_ip = get_my_ip(socket.peerhost)
              PayloadLog.create(
                :exploit => caused_by,
                :payload => data,
                :src_addr => my_ip,
                :dest_addr => socket.peerhost,
                :src_port => socket.localport,
                :dest_port => socket.peerport,
                :task_id => task.id
              )
            end
          end
          exec_task task
        rescue ::Exception
          puts "An error occurred while executing task ##{task.id}", $!, *$!.backtrace
          task.error = $!.to_s
          task.save
          raise
        end
      end
    end

  private
  
    def exec_task task, async = true
      cmd_args = task.module.split
      command = "cmd_#{cmd_args.shift}".to_sym
      if @@commands.include? command
        if async
          thread = Thread.new do
            begin
              task.progress = 1
              task.status = "running asynchron"
              task.save
              send command.to_sym, :args => cmd_args, :task => task
              task.progress = 100
              task.status = "done"
              task.save
            rescue ::Exception
              puts "Failed executing '#{command}(#{cmd_args.join ', '})' on task ##{task.id}.", $!, *$!.backtrace
              task.progress = -1
              task.status = "failed"
              task.error = $!.to_s
              task.save
            end
          end
        else
          task.progress = 1
          task.status = "running"
          task.save
          send command.to_sym, :args => cmd_args, :task => task
          task.progress = 100
          task.status = "done"
          task.save
        end
      else
        raise "Unknown command: #{command}."
      end
    end
  
    # Returns the IP address of that interface, which would connect to
    # an address of the given +iprange+.
    #
    # @param [String] iprange An IP address (like +127.0.0.1+) or a
    #                 CIDR range (like +192.168.1.0/24+)
    # @return [String] An IP address.
    # @see https://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
    def get_my_ip iprange
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
      UDPSocket.open do |s|
        # udp is stateless, so there is no real connect
        s.connect IPAddr.new(iprange).to_s, 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end

    def run_exploit mod_name, options, non_blocking = false
      begin
        mod = nil
        unless (mod = @framework.modules.create(mod_name))
          puts("Failed to initilize #{mod_name}")
          return
        end

        options.each_pair do |key, value|
          mod.datastore[key] = value
        end

        cur_thread = Thread.new(mod) do |thread_mod|
          begin
            case thread_mod.type
            when Msf::MODULE_EXPLOIT
              thread_mod.exploit_simple(
                'Payload'  => thread_mod.datastore['PAYLOAD'],
                'Quiet'    => true,
                'RunAsJob' => false
              )
            when Msf::MODULE_AUX
              thread_mod.run_simple(
                'Quiet'    => true,
                'RunAsJob' => false
              )
            end
          rescue ::Exception
            puts(" >> subnet_manager exception during launch from #{mod_name}: #{$!} ") if $MY_DEBUG
          end
        end
      rescue ::Interrupt
        raise $!
      rescue ::Exception
        puts(" >> subnet_manager: exception from #{mod_name}: #{$!} #{$!.backtrace}")
      end
      return cur_thread if non_blocking
      cur_thread.join
    end

    def connect_db
      # set the db driver
      @framework.db.driver = DB_SETTINGS["adapter"]
      # create the options hash
      opts = {}
      opts['adapter'] = DB_SETTINGS["adapter"]
      opts['username'] = DB_SETTINGS["username"]
      opts['password'] = DB_SETTINGS["password"]
      opts['database'] = DB_SETTINGS["database"]
      opts['host'] =  DB_SETTINGS["host"]
      opts['port'] =  DB_SETTINGS["port"]
      opts['socket'] = DB_SETTINGS["socket"]

      # This is an ugly hack for a broken MySQL adapter:
      # http://dev.rubyonrails.org/ticket/3338
      # if (opts['host'].strip.downcase == 'localhost')
      #   opts['host'] = Socket.gethostbyname("localhost")[3].unpack("C*").join(".")
      # end
      puts "Connecting to database..."

      begin
        unless @framework.db.connect(opts)
          raise RuntimeError.new "Failed to connect to the database: #{@framework.db.error}. Did you edit the config.yaml?"
        end
      rescue ::Exception
        puts "Unable to connect to database."
        raise
      end

      puts "Connected to database."
    end

    def disconnect_db
      puts "Disconnecting database..."
      @framework.db.disconnect
      puts "Disconnected."
    end

    def load_plugins
      begin
        require "fidius/msf_plugins/msf_payload_loader.rb"
        @framework.plugins.load("fidius/msf_plugins/payload_logger")
      rescue ::Exception
        puts "An error occurred while loading plugins", $!, *$!.backtrace
      end
    end
  end
end

