require "#{RAILS_ROOT}/script/worker/loader"

class MsfSessionEvent
  include ::Msf::SessionEvent

  #
  # Called when a session is opened.
  #
  def on_session_open(session)
    puts("on_session_open #{session}")
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
