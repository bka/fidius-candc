require 'pp'

# Function for running arp -a on the owned host
def save_arp_a

  # dmke: Was passiert hier, und warum gerade so?
  # Ein Array `a` wird angelegt und _exakt_ ein (Thread-) Objekt darin
  # abgelegt. Dieser Thread arbeitet fröhlich im Hintergrund, und wir
  # warten am Ende (aktiv) darauf, dass er fertig wird.
  #
  # Das führt zu folgenden Fragen:
  # * Aktives Warten? `t = Thread.new {}; t.join` ist resourcensparender,
  #   benötigt kein Array, und schon gar keine aberwitzige Zeile 57.
  # * Wird überhaupt ein Thread benötigt, wenn `save_arp_a()` am Ende
  #   auf Beendigung desselben wartet?
  #
  # Weitere Kleinigkeiten:
  # * Zeile 35 match auch auf 999.999.999.999
  # * Zeile 37 würde auch "xj-z-?.-@3-..." matchen "\S = nicht Whitespace"
  # * Zeile 51: Warum kein re-raise?
  # * Zeile 53: unnötig

  a = []
  @client.response_timeout=120
  cmd = 'arp -a'
  a.push(::Thread.new {
    r, cmdout = '', ''  
    r = @client.sys.process.execute(cmd, nil, {'Hidden' => true, 'Channelized' => true})
    while d = r.channel.read
      cmdout << d
    end
    begin 
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
    rescue 
      puts $!
    end
    cmdout = ""
    r.channel.close
    r.close
  })
  a.delete_if {|x| not x.alive?} while not a.empty?
end

def get_host_infos
  sysinfo = client.sys.config.sysinfo
  # I'm confused: minor 'os', but capital 'Computer' etc.?
  hostdata = {
    :os => sysinfo['OS'],
    :Computer => sysinfo['Computer'],
    :Arch => sysinfo['Architecture'],
    :Language => sysinfo['System Language']
  }
end

save_arp_a
pp get_host_infos
