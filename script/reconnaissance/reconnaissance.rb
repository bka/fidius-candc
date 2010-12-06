require 'pp'

#dmke:
# Weitere Kleinigkeiten:
# * Zeile 20 match auch auf 999.999.999.999
# * Zeile 22 würde auch "xj-z-?.-@3-..." matchen "\S = nicht Whitespace"

# Function for running arp -a on the owned host
def save_arp_a
  @client.response_timeout=120
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
      if session.framework.db.active
        session.framework.db.report_host(
          :workspace => session.framework.db.workspace,
          :host => b.first.to_s,
          :mac  => c
        )
      end
    end
  end
  r.channel.close
  r.close
end

def get_host_infos
  sysinfo = client.sys.config.sysinfo
  hostdata = {
    :os => sysinfo['OS'],
    :computer => sysinfo['Computer'],
    :arch => sysinfo['Architecture'],
    :language => sysinfo['System Language']
  }
end

save_arp_a
pp get_host_infos
