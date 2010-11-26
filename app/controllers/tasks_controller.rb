class TasksController < ApplicationController
  include DrbHelper

  def index
    @tasks = Msf::DBManager::Task.all
  end

  def show
    @task = Msf::DBManager::Task.find params[:id]
  end

  def start_worker
    msf_worker "start"
    flash[:notice] = "Starting worker. Try again in a few seconds."
    redirect_to :controller => :tasks, :action => :index
  end
  
  def stop_worker
    msf_worker "stop"
    flash[:notice] = "Worker stopped."
    redirect_to :controller => :tasks, :action => :index
  end

  def scan
    @subnet = params[:subnet]
    begin
      task = Msf::DBManager::Task.create(:module => "autopwn #{@subnet}")
      get_msf_worker.task_created
      flash[:notice] = "Task #{task.id} started."
      redirect_to :controller => :tasks, :action => :index
    rescue Exception
      task.destroy
      msf_worker "start"
      flash[:error] = "Sorry, worker was not working. Try again in a few seconds."
      index
      render :action => :index
    end
  end

  def addroutetosession
    begin
      task = Msf::DBManager::Task.create(:module => "add_route_to_session #{params[:sessionID]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :controller => :tasks, :action => :index
    rescue
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :controller => :tasks, :action => :index
    end
  end

  def arpscannsession
    begin
      task = Msf::DBManager::Task.create(:module => "arp_scann_session #{params[:sessionID]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :controller => :tasks, :action => :index
    rescue
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :controller => :tasks, :action => :index
    end
  end

end
