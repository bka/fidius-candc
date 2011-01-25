module FIDIUS::MsfWorker::ArpScan
  
  # Not documentated yet.
  #
  # Call sequence:
  #   cmd_add_route_to_session(:args => [], :task => nil)
  #
  # @param [Array] args  Arguments.
  # @param [Task] task  A Task ActiveRecord.
  FIDIUS::MsfWorker.register_command :add_route_to_session do |options|
    args = options[:args]
    task = options[:task]
    puts "add_route_to_session"
    session = get_session_by_uuid @framework.sessions, args[0]
    return unless session
    return unless session.type == 'meterpreter'
    FIDIUS::Session::add_route_to_session(session)
  end
  
  # Not documentated yet.
  #
  # Call sequence:
  #   cmd_arp_scann_session(:args => [], :task => nil)
  #
  # @param [Array] args  Arguments.
  # @param [Task] task  A Task ActiveRecord.
  FIDIUS::MsfWorker.register_command :arp_scann_session do |options|
    args = options[:args]
    task = options[:task]
    session = get_session_by_uuid @framework.sessions, args[0]
    return unless session
    return unless session.type == 'meterpreter'
    session.net.config.each_route do |route|
      # Remove multicast and loopback interfaces
      next if route.subnet =~ /^(224\.|127\.)/
      next if route.subnet == '0.0.0.0'
      next if route.netmask == '255.255.255.255'
      next if (IPAddr.new "#{route.subnet}/#{route.netmask}").include? IPAddr.new( FIDIUS::Session::get_lhost session)
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

private
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

  # Returns the session from the +sessions+ array with the UUID +uuid+.
  def get_session_by_uuid sessions, uuid
    sessions.each_sorted do |s|
      if session = sessions.get(s)
        return session if session.uuid == uuid
      end
    end
  end
end

class FIDIUS::MsfWorker
  include FIDIUS::MsfWorker::ArpScan
end
