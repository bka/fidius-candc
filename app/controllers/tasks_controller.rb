require 'drb'

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
      task = Msf::DBManager::Task.create(:module=>"autopwn #{params[:subnet]}")
      get_msf_worker.task_created
      flash[:notice] = "Task started"
      redirect_to :controller=>:tasks, :action=>:index
    rescue
      task.destroy
      flash[:error] = "Sorry worker is not working. try script/msf-worker start"
      redirect_to :controller=>:tasks, :action=>:index
    end
  end
end
