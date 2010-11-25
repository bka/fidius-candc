require 'rubygems'
require "#{RAILS_ROOT}/script/worker/loader"
require "#{RAILS_ROOT}/script/worker/msf_session_event"
require "#{RAILS_ROOT}/script/worker/prelude_event_fetcher.rb"
require "#{RAILS_ROOT}/script/worker/ip_helper.rb"
require 'drb'


puts "msf-worker start"

module CommandHandler
  class CommandReceiver
    include FIDIUS
    
    def initialize
      puts "Initialize Framework..."
      @framework =  Msf::Simple::Framework.create
      puts "done."
      connect_db
      begin
        @framework.db.exploited_hosts.each do |h|
          h.delete
        end
      rescue ::Exception
        puts("An error occurred while deleteing exploited_hosts: #{$!} #{$!.backtrace}")
      end

      handler = MsfSessionEvent.new
      @framework.events.add_session_subscriber(handler)
      @prelude_fetcher = PreludeEventFetcher.new
      load_plugins
    end

    def exec_task task, async = true
      cmd = task.module.split
      if commands.has_key? cmd[0].to_s
        if(async)
          thread = Thread.new do
            begin      
              send("cmd_#{cmd[0]}".to_sym, cmd[1..-1], task)
              task.progress = 100
              task.save
            rescue ::Exception
              puts("problem in session_action: #{$!} #{$!.backtrace}")
            end
          end
        else
          send("cmd_#{cmd[0]}".to_sym, cmd[1..-1], task)
          task.progress = 100
          task.save
        end
      else
        raise "Unknown Command"
      end
    end

    def commands
      base = {
          "autopwn" => "Starts Autopwning",
          "nmap" => "Starts a Nmap Scan",
          "session_install" => "Install meterpreter on host"
      }
    end

    def cmd_nmap args, task=nil
      manager = SubnetManager.new @framework, args[0]
      manager.run_nmap
    end

    def cmd_session_install args
      if (session = @framework.sessions.get(args[0]))
        if (session.type == "meterpreter")
          puts "Install meterpreter on session."
          install_meterpreter(session)
        else
         puts "Selected session is not a meterpreter session"
        end
      else
        puts "No such session found"
      end
    end

    def cmd_autopwn args, task=nil
      autopwn args[0], task
    end

    def autopwn iprange, task=nil
      @prelude_fetcher.attack_started
      manager = SubnetManager.new @framework, iprange, 1
      manager.get_sessions
      @prelude_fetcher.get_events(get_my_ip iprange).each do |ev|
        PreludeLog.create(
          :task_id => task.id,
          :payload => ev.payload,
          :detect_time => ev.detect_time,
          :dest_ip => ev.dest_ip,
          :src_ip => ev.source_ip,
          :text => ev.text,
          :severity => ev.severity,
          :analyzer_model => ev.analyzer_model,
          :ident => ev.id
        )
      end
    end

    def nmap iprange, async = true
      manager = SubnetManager.new @framework, iprange, 1
      manager.run_nmap
    end

    def cmd_session_install sessionID
      if (session = @framework.sessions.get(sessionID))
        if (session.type == "meterpreter")
          return "Install meterpreter on session."
          install_meterpreter(session)
        else
         return "Selected session is not a meterpreter session"
        end
      else
        return "No such session found"
      end
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
      puts opts
      puts "connecting to database..."

      begin
        if (not @framework.db.connect(opts))
          raise RuntimeError.new("Failed to connect to the database: #{@framework.db.error}. Did you edit the config.yaml?")
        end
      rescue ::Exception
        puts("An error occurred while connecting to database: #{$!} #{$!.backtrace}")
      end

      puts "connected to database."
    end

    def task_created
      Msf::DBManager::Task.find_new_tasks.each do |task|
        begin
          task.progress = 1
          task.save
          Msf::Plugin::FidiusLogger.on_log do |caused_by,data,socket|
            PayloadLog.create(
              :exploit => caused_by,
              :payload => data,
              :src_addr => get_my_ip(socket.peerhost),
              :dest_addr => socket.peerhost,
              :src_port => socket.localport,
              :dest_port => socket.peerport,
              :task_id => task.id
            )
          end
          exec_task task
        rescue ::Exception
          puts("An error occurred while executing task#{task.inspect}: #{$!} #{$!.backtrace}")
          task.error = $!.inspect
          task.save
        end
      end
    end

    def load_plugins
      begin
        require "#{RAILS_ROOT}/script/worker/msf_payload_loader.rb"
        @framework.plugins.load("#{RAILS_ROOT}/script/worker/msf_plugins/payload_logger")
      rescue ::Exception
        puts("An error occurred while loading plugins: #{$!} #{$!.backtrace}")
      end
    end
  end
end

if not MSF_SETTINGS.select("/drb_url")
  puts "please specify drb_url in msf.yml"
  return
end

DRb.start_service MSF_SETTINGS.select("/drb_url").first.value, CommandHandler::CommandReceiver.new

puts DRb.uri
File.open(File.join(RAILS_ROOT, 'tmp', 'pids', 'msf-worker'), 'w') do |f|
  f.puts Process.pid
end

DRb.thread.join
