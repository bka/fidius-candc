def disable_firewall session, mode="DISABLE", exception = nil
    exception ||= mode
    execute_cmd_with_channel "netsh firewall set opmode #{mode} #{mode}"
end

def read_firewall_config session
    result = execute_cmd_with_channel "netsh firewall show state"
    unless result[:error]
        result[:firewall_state] = "unknown"
        result[:channel].split("\n").each do |o|
          if (o.include? "Betriebsmodus")
            state = ""
            if o.include? "Inaktiv"
                state = "DISABLE"
            elsif o.include? "Aktiv"
                state = "ENABLE"                
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
    cmd = "netsh firewall add portopening TCP #{port} #{rule_name}"
    execute_cmd_with_channel cmd
end

#todo
def execute_cmd_with_channel cmd_string
  open_port = session.sys.process.execute("cmd.exe /c #{cmd_string}", nil, {'Hidden' => 'true','Channelized' => true})
  result = {}
  result[:channel] = ""
  while(d = open_port.channel.read)
	if d =~ /The requested operation requires elevation./
			result[:error] = "Couldn't Open port'"
    else
      result[:channel] << d
    end
  end
  open_port.channel.close
  open_port.close 1#Was auch immer der Parameter macht
  result
end
