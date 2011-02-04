class TasksController < ApplicationController
  include DrbHelper

  def index
    @tasks = Msf::DBManager::Task.all
  end

  def show
    @task = Msf::DBManager::Task.find params[:id]
  end

  def clean
    @tasks = Msf::DBManager::Task.all(:conditions=>"status='done' || status='failed'")
    @tasks.each do |task|
      task.destroy
    end
    redirect_to :tasks
  end

  def scan
    @subnet = params[:subnet]
    begin
      task = Msf::DBManager::Task.create(:module => "autopwn #{@subnet}")
      get_msf_worker.task_created
      flash[:notice] = "Task #{task.id} started."
      redirect_to :hosts
    rescue Exception
      task.destroy
      msf_worker "start"
      flash[:error] = "Sorry, worker was not started. Try again in a few seconds."
      index
      redirect_to :hosts
    end
  end

  def addroutetosession
    begin
      task = Msf::DBManager::Task.create(:module => "add_route_to_session #{params[:sessionID]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :hosts
    rescue
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :hosts
    end
  end

  def execreconnaissance
    begin
      task = Msf::DBManager::Task.create(:module => "exec_reconnaissance #{params[:sessionID]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :hosts
    rescue
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :hosts
    end
  end

  def arpscannsession
    begin
      task = Msf::DBManager::Task.create(:module => "arp_scann_session #{params[:sessionID]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :controller => :hosts, :action => :index
    rescue
      task.destroy
      flash[:error] = "Sorry, worker is not working. Try <code>ruby script/msf-worker start</code>."
      redirect_to :hosts
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

  def startfileautopwn
    begin
      task = Msf::DBManager::Task.create(:module => "start_file_autopwn #{params[:address]}")
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
