class MultihandlersController < ApplicationController

  def index
    begin
      @worker = get_msf_worker
      @interfaces = @worker.cmd_get_interfaces
      unless @interfaces.empty?
        @interfaces << '0.0.0.0'
      end
      @multihandlers = @worker.cmd_get_running_multihandler
    rescue
      nil
    end
  end
  
  def create
    @worker = get_msf_worker
    @worker.cmd_start_multihandler 'payload' => params[:payload][:payload], 'lport' => params[:port], 'lhost' => params[:interface] rescue nil
    redirect_to multihandlers_url  
  end
  
  def stop
    @worker = get_msf_worker
    @worker.cmd_stop_multihandler :jid => params[:jid] rescue nil
    redirect_to multihandlers_url  
  end
  
  def auto_complete_for_payload_payload()  
    query = params[:payload][:payload]
    @items = []
    payloads = get_msf_worker.cmd_get_payloads rescue nil
    if payloads
      payloads.each_key do |key|
        @items << {'payload' => key.to_s} if key.include? query
      end
    end
    render :inline => "<%= auto_complete_result @items, 'payload' %>" 
  end 
end
