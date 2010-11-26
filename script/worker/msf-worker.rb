require 'rubygems'
require "#{RAILS_ROOT}/script/worker/loader"
require "#{RAILS_ROOT}/script/worker/msf_session_event"
require "#{RAILS_ROOT}/script/worker/prelude_event_fetcher.rb"
require 'drb'

module FIDIUS
  class MSFWorker
    def puts *obj # :nodoc:
      if ob = obj.shift
        $stdout.puts "[#{Time.now.strftime '%Y-%m-%d %H:%M:%S'}] FIDIUS MSF worker: #{ob}"
        obj.each {|o| $stdout.puts "\t#{o}" } if obj.size > 0
      end
    end

    def initialize
      puts "Generated new worker object."
    end
    
    def start
      puts "Starting. Will listen on #{DRb.uri}..."
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

      handler = MsfSessionEvent.new
      @framework.events.add_session_subscriber(handler)
      @prelude_fetcher = PreludeEventFetcher.new
      load_plugins
      puts "Started."
    end
    

    def exec_task task, async = true
      cmd = task.module.split
      command = "cmd_#{cmd.shift}"
      if commands.include? command
        if async
          thread = Thread.new do
            begin
              send command.to_sym, cmd, task
              task.progress = 100
              task.save
            rescue ::Exception
              puts "Failed executing '#{command}, #{cmd.join ', '}' on task ##{task.id}.", $!, *$!.backtrace
            end
          end
        else
          send command.to_sym, cmd, task
          task.progress = 100
          task.save
        end
      else
        raise "Unknown command: #{command}."
      end
    end

    def commands
      @commands ||= (self.methods - Object.instance_methods).select do |m|
        m =~ /^cmd_/
      end
      @commands
    end

    def cmd_nmap args, task = nil
      manager = SubnetManager.new @framework, args[0]
      manager.run_nmap
    end

    def cmd_session_install args
      session = get_session_by_uuid(@framework.sessions, args[0])
      return unless session
      return unless session.type == 'meterpreter'
      install_meterpreter(session)
    end
    
    def cmd_add_route_to_session args, task=nil
      session = get_session_by_uuid(@framework.sessions, args[0])
      return unless session
      return unless session.type == 'meterpreter'
      sb = Rex::Socket::SwitchBoard.instance
      session.net.config.each_route do |route|
        # Remove multicast and loopback interfaces
        next if route.subnet =~ /^(224\.|127\.)/
        next if route.subnet == '0.0.0.0'
        next if route.netmask == '255.255.255.255'
        unless sb.route_exists?(route.subnet, route.netmask)
          puts "AutoAddRoute: Routing new subnet #{route.subnet}/#{route.netmask} through session #{session.sid}"
          sb.add_route(route.subnet, route.netmask, session)
        end
      end
    end

    def get_session_by_uuid sessions, uuid
      sessions.each_sorted do |s|
        if ((session = sessions.get(s)))
          return session if session.uuid == uuid
        end
      end
    end

    def cmd_autopwn args, task = nil
      autopwn args[0], task
    end

    # XXX: obsolete?
    def nmap iprange, async = true
      manager = SubnetManager.new @framework, iprange, 1
      manager.run_nmap
    end

    def cmd_arp_scann_session args, task=nil
      session = get_session_by_uuid(@framework.sessions, args[0])
      return unless session
      return unless session.type == 'meterpreter'
      session.net.config.each_route do |route|
        # Remove multicast and loopback interfaces
        next if route.subnet =~ /^(224\.|127\.)/
        next if route.subnet == '0.0.0.0'
        next if route.netmask == '255.255.255.255'
        mask = IPAddr.new(route.netmask).to_i.to_s(2).count("1")
        arp_scann(session, "#{route.subnet}/#{mask}")
      end
    end

    def autopwn iprange, task = nil
      @prelude_fetcher.attack_started
      manager = SubnetManager.new @framework, iprange, 1
      s = manager.get_sessions
      my_ip = get_my_ip iprange
      @prelude_fetcher.get_events(my_ip).each do |ev|
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

    def arp_scann(session, cidr)
      puts("ARP Scanning #{cidr}")
      ws = session.railgun.ws2_32
      iphlp = session.railgun.iphlpapi
      i, a = 0, []
      iplst,found = [],""
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
              mac_str = mac[0].ord.to_s(16) + ":" +
                  mac[1].ord.to_s(16) + ":" +
                  mac[2].ord.to_s(16) + ":" +
                  mac[3].ord.to_s(16) + ":" +
                  mac[4].ord.to_s(16) + ":" +
                  mac[5].ord.to_s(16)
              puts "IP: #{ip_text} MAC #{mac_str}"
              found << "#{ip_text}\n"
              if session.framework.db.active
                session.framework.db.report_host(
                  :workspace => session.framework.db.workspace,
                  :host => ip_text,
                  :mac  => mac_str.to_s.strip.upcase
                )
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

    def task_created
      Msf::DBManager::Task.find_new_tasks.each do |task|
        begin
          task.progress = 1
          task.save
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
          exec_task task
        rescue ::Exception
          puts "An error occurred while executing task ##{task.id}", $!, *$!.backtrace
          task.error = $!.inspect
          task.save
          raise
        end
      end
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
File.open(File.join(RAILS_ROOT, 'tmp', 'pids', 'msf-worker'), 'w') do |f|
  f.puts Process.pid
end
worker.start

DRb.thread.join

FIDIUS.puts "Exiting."

