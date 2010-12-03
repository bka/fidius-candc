#-------------------------------------------------------------------------------
# Function for running arp -a on the owned host
def list_arp_a()
	a =[]
	@client.response_timeout=120
	cmd = "arp -a"
	a.push(::Thread.new {
		r,cmdout='',""	
		print_status "\trunning command #{cmd}"
		r = @client.sys.process.execute(cmd, nil, {'Hidden' => true, 'Channelized' => true})
		while(d = r.channel.read)
			# Überprüfen von jeder Zeile die wir von der Windows cmd bekommen. Ip-Adressen auslesen, sowie die MAC-Adresse
			cmdout << d
		end
		# durch die Ausgabe iterieren und nach IP-Adressen und MAC-Adressen suchen
		cmdout.split("\n").each do |line|
			# herausfiltern einer IP-Adresse aus einer Zeile
			b = line.scan(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
			# herausfiltern der dazugehörigen MAC-Adresse
			c = line.scan(/\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}\-\S{1,2}/)
			# Schreiben der gefundenen IP- und MAC-Adressen in die Datenbank
			if not b.empty? and not c.empty?
				c.gsub('-',':')
				if session.framework.db.active
					session.framework.db.report_host(
					:workspace => session.framework.db.workspace,
					:host => b.first.to_s,
					:mac  => c.first.to_s
					) 			
				end
			end
		end
			
		cmdout = ""
		r.channel.close
		r.close
		})
	a.delete_if {|x| not x.alive?} while not a.empty?
end

list_arp_a()

