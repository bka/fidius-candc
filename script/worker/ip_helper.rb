require 'ipaddr' # used to gain a single address from a ip range
require 'socket' # used to determine this host's ip

module FIDIUS

  #
  # returns the ip address of that interface, which would connect to
  # an address of the given +iprange+.
  # 
  # see also https://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
  #
  def get_my_ip iprange
    puts "get_my_ip #{iprange}"
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
    UDPSocket.open do |s|
      # udp is stateless, so there is no real connect
      s.connect IPAddr.new(iprange).to_s, 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end

end
