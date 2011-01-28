class MultihandlersController < ApplicationController

  def index
    @worker = get_msf_worker
    @interfaces = get_interfaces
    @multihandlers = @worker.cmd_get_running_multihandler rescue nil
  end
  
  def create
    @worker = get_msf_worker
    @worker.cmd_start_multihandler params[:payload][:payload], params[:port], params[:interface] #TODO: rescue nil
    redirect_to multihandlers_url  
  end
  
  def stop
    @worker = get_msf_worker
    @worker.cmd_stop_multihandler params[:jid]
    redirect_to multihandlers_url  
  end
  
def auto_complete_for_payload_payload()  
  query = params[:payload][:payload]
  @items = []
  payloads = get_msf_worker.cmd_get_payloads rescue nil
  if payloads
    payloads.each_key do |key|
      @items << key.to_s if key.include? query
    end
  end
  render :inline => "<%= auto_complete_without_model @items, 'payload' %>" 
end 
  private
  
   def get_interfaces
    cmd = IO.popen('which ifconfig'){ |f| f.readlines[0] }
    raise RuntimeError.new("ifconfig not in PATH") unless !cmd.nil?
    @ifconfig = IO.popen("/sbin/ifconfig -a"){ |f| f.readlines.join }
    r = @ifconfig.scan(/inet Adresse:((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))/).flatten
  end
end
