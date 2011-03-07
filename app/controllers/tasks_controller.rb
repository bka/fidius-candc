class TasksController < ApplicationController

  def index
    @tasks = Task.all
    t = render_to_string :template=>"tasks/index", :layout=>false
    render :update do |page|
      page <<%{
        $('#tasks_dialog').html("#{escape_javascript(t)}");
      }
    end
  end

  def show
    @task = Task.find params[:id]
  end

  def clean
    raise "Not Implemented"
    redirect_to :tasks
  end

  def scan
    #params[:subnet]
    raise "Not Implemented"
  end

  def addroutetosession
    #params[:sessionID]
    raise "Not Implemented"
  end

  def execreconnaissance
    #params[:sessionID]
    raise "Not Implemented"
  end

  def arpscannsession
    #params[:sessionID]
    raise "Not Implemented"
  end

  def installpersistence
    #params[:sessionID]
    raise "Not Implemented"
  end

  def startbrowserautopwn
    #params[:address]
    raise "Not Implemented"
  end
end
