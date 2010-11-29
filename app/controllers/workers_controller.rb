class WorkersController < ApplicationController
  include DrbHelper

  def index
    require 'drb'

    @current_server = DRb.current_server rescue DRb.start_service
  end

  def start
    msf_worker "start"
    flash[:notice] = "Starting MSF worker. This may take some time."
    redirect_to :workers
  end

  def stop
    msf_worker "stop"
    flash[:notice] = "MSF worker stopped."
    redirect_to :workers
  end

  def restart
    msf_worker "restart"
    flash[:notice] = "Restarting MSF worker. This may take some time."
    redirect_to :workers
  end

end
