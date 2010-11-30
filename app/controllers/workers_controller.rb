class WorkersController < ApplicationController
  include DrbHelper

  def index
    @worker_status = get_msf_worker.status rescue 'not running'
    @logs = WorkerLog.all :order => ['created_at DESC']
  end

  def start
    msf_worker "start"
    flash[:notice] = "Starting MSF worker. This may take some time."
    redirect_to :back
  end

  def stop
    msf_worker "stop"
    flash[:notice] = "MSF worker stopped."
    redirect_to :back
  end

  def restart
    msf_worker "restart"
    flash[:notice] = "Restarting MSF worker. This may take some time."
    redirect_to :back
  end

end
