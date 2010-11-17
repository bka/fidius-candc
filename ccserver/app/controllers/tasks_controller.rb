class TasksController < ApplicationController
  def index
    @tasks = Msf::DBManager::Task.all
  end

  def show
    @task = Msf::DBManager::Task.find params[:id]
  end

  def scan
    Msf::DBManager::Task.create(:module=>"autopwn #{params[:subnet]}")
    #output = open("commands","w+")
    #output.puts "autopwn #{params[:subnet]}"
    #output.flush
    flash[:notice] = "Task started"
    redirect_to :controller=>:tasks, :action=>:index
  end
end
