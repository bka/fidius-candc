class TasksController < ApplicationController
  include DrbHelper

  def index
    @tasks = Msf::DBManager::Task.all
  end

  def show
    @task = Msf::DBManager::Task.find params[:id]
  end

  def scan
    begin
      task = Msf::DBManager::Task.create(:module => "autopwn #{params[:subnet]}")
      get_msf_worker.task_created
      flash[:notice] = "Task #{task.id} started."
      redirect_to :controller => :tasks, :action => :index
    rescue Exception
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :controller => :tasks, :action => :index
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
