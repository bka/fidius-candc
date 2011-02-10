class BrowserAutopwnController < ApplicationController

  def index
    begin
      @worker = get_msf_worker
      @interfaces = @worker.cmd_get_interfaces
    rescue
      nil
    end
    @interfaces ||= []
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
