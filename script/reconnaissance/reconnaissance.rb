# Function for running arp -a on the owned host
def list_arp_a()
  a =[]
  @client.response_timeout=120
  cmd = "arp -a"
  a.push(::Thread.new {
    r,cmdout='',""  
    r = @client.sys.process.execute(cmd, nil, {'Hidden' => true, 'Channelized' => true})
    while(d = r.channel.read)
      cmdout << d
    end
    begin 
      cmdout.split("\n").each do |line|
        # extract ip-adresses
        b = line.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
        # extract MAC-adresses
        c = line.scan(/\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}/)
        # write found ip- and mac adress in database           
        if not b.empty? and not c.empty?
          c = c.first.to_s.gsub('-',':')
          if session.framework.db.active
            session.framework.db.report_host(
              :workspace => session.framework.db.workspace,
              :host => b.first.to_s,
              :mac  => c)           
          end
        end
      end
    rescue 
      puts $!
    end
    cmdout = ""
    r.channel.close
    r.close
  })
  a.delete_if {|x| not x.alive?} while not a.empty?
end

list_arp_a()