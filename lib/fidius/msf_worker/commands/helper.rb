module FIDIUS::MsfWorker::Helpers
  FIDIUS::MsfWorker.register_command :get_interfaces do
    get_interfaces
  end
  
  private
  
  def get_interfaces
    cmd = IO.popen('which ifconfig'){ |f| f.readlines[0] }
    raise RuntimeError.new("ifconfig not in PATH") unless !cmd.nil?
    @ifconfig = IO.popen("/sbin/ifconfig -a"){ |f| f.readlines.join }
    r = @ifconfig.scan(/inet Adresse:((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))/).flatten
  end
  
end

class FIDIUS::MsfWorker
  include FIDIUS::MsfWorker::Helpers
end
