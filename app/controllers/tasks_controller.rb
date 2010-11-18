class TasksController < ApplicationController
  def index

  end

  def scan
    output = open("commands","w+")
    output.puts "autopwn #{params[:subnet]}"
    output.flush
    flash[:notice] = "Scan started"
    redirect_to :root
  end
end
