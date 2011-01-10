class TasksController < ApplicationController
  include DrbHelper

  def index
    @tasks = Msf::DBManager::Task.all
  end

  def show
    @task = Msf::DBManager::Task.find params[:id]
  end

  def scan
    @subnet = params[:subnet]
    begin
      task = Msf::DBManager::Task.create(:module => "autopwn #{@subnet}")
      get_msf_worker.task_created
      flash[:notice] = "Task #{task.id} started."
      redirect_to :tasks
    rescue Exception
      task.destroy
      msf_worker "start"
      flash[:error] = "Sorry, worker was not started. Try again in a few seconds."
      index
      render :action => :index
    end
  end

  def addroutetosession
    begin
      task = Msf::DBManager::Task.create(:module => "add_route_to_session #{params[:sessionID]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :tasks
    rescue
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :tasks
    end
  end

  def execreconnaissance
    begin
      task = Msf::DBManager::Task.create(:module => "exec_reconnaissance #{params[:sessionID]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :tasks
    rescue
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :tasks
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
      redirect_to :tasks
    end
  end

  def installpersistence
    begin
      task = Msf::DBManager::Task.create(:module => "session_install #{params[:sessionID]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :controller => :tasks, :action => :index
    rescue
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :tasks
    end
  end

  def startbrowserautopwn
    begin
      task = Msf::DBManager::Task.create(:module => "start_browser_autopwn #{params[:address]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :controller => :tasks, :action => :index
    rescue
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :tasks
    end
  end

end
