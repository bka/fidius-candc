module FIDIUS::MsfWorker::Multihandler

  FIDIUS::MsfWorker.register_command :stop_multihandler do |options|
    @framework.stop_multihandler options[:jid]
  end
  
  FIDIUS::MsfWorker.register_command :start_multihandler do |options|
    puts "Starting MultiHandler: #{options[:payload]} on #{options[:lhost]}:#{options[:lport]}"
    run_multihandler options[:payload], options[:lport], options[:lhost]
  end

  FIDIUS::MsfWorker.register_command :get_running_multihandler do
    @framework.get_running_multihandler
  end

  FIDIUS::MsfWorker.register_command :get_payloads do
    @framework.payloads
  end

end

class FIDIUS::MsfWorker
  include FIDIUS::MsfWorker::Multihandler
end
