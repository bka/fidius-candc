require 'pp'
puts "start script"
#dmke:
# Weitere Kleinigkeiten:
# * Zeile 20 match auch auf 999.999.999.999
# * Zeile 22 würde auch "xj-z-?.-@3-..." matchen "\S = nicht Whitespace"

# Function for running arp -a on the owned host
def get_arp_a_infos
  hosts = Array.new
  cmd = 'arp -a'
  r, cmdout = '', ''  
  r = @client.sys.process.execute(cmd, nil, {'Hidden' => true, 'Channelized' => true})
  while d = r.channel.read
    cmdout << d
  end 
  cmdout.split("\n").each do |line|
    # extract ip-adresses
    ip = line.scan /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    # extract MAC-adresses
    mac = line.scan /\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}/
    # write found ip- and mac adress in database           
    if not ip.empty? and not mac.empty?
      mac = mac.first.to_s.gsub('-',':')
      hosts << {
        :workspace => session.framework.db.workspace,
        :host => ip.first.to_s,
        :mac  => mac
      }
    end
  end
  r.channel.close
  r.close
  return hosts
end

# Function for running ipconfig -all on the owned host
def get_host_infos
  hostdata = Hash.new
  hostdata[:workspace] = session.framework.db.workspace
  r, cmdout = '', '' 
  r = @client.sys.process.execute('ipconfig /all', nil, {'Hidden' => true, 'Channelized' => true})
  while d = r.channel.read
    cmdout << d
  end 
	
  ips = Array.new
  macs = Array.new
  
  cmdout.split("\n").each do |line|
	# extract ip-adresses
	ip = (line.scan /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
	if ip[0] != nil
	  ips << ip
	end
	# extract MAC-adresses
	mac = (line.scan /\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}/)
	if mac[0] != nil
	  mac[0] = mac[0].gsub('-',':')
	  macs << mac
	end	
  end
  # write all information about the host in the database
  sysinfo = client.sys.config.sysinfo
  
  hostdata[:os_name]   = (sysinfo['OS'].split'(')[0].strip
  hostdata[:os_flavor] = ((sysinfo['OS'].split'(')[1].split',')[0].strip  
  hostdata[:host]      = ips[0][0]
  hostdata[:mac]       = macs[0][0]
  hostdata[:os_sp]     = (((sysinfo['OS'].split'(')[1].split',')[1].split')')[0].strip
  hostdata[:name]      = sysinfo['Computer']
  hostdata[:arch]      = sysinfo['Architecture']
  hostdata[:os_lang]   = sysinfo['System Language']
   
  return hostdata
end

def write_db host
  puts "write to db"
  if session.framework.db.active
    puts "DB active"
    session.framework.db.report_host host
  end

end

get_arp_a_infos.each do |host|
  write_db host
end

write_db get_host_infos
