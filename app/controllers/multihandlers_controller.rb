class MultihandlersController < ApplicationController

  def index
    @worker = get_msf_worker
    @multihandlers = @worker.cmd_get_running_multihandler rescue nil
  end
  
  def create
    @worker = get_msf_worker
    @worker.cmd_start_multihandler params[:payload], params[:port], params[:interface] rescue nil
    redirect_to multihandlers_url  
  end
  
  def stop
    p params
    @worker = get_msf_worker
    @worker.cmd_stop_multihandler params[:jid]
    redirect_to multihandlers_url  
  end

end
