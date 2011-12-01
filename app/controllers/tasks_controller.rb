class TasksController < ApplicationController

  def index
    @tasks = Task.all
    t = render_to_string :template=>"tasks/index", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
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
    raise "Not Implemented"
  end

  def addroutetosession
    raise "Not Implemented"
  end

  def execreconnaissance
    raise "Not Implemented"
  end

  def arpscannsession
    raise "Not Implemented"
  end

  def installpersistence
    raise "Not Implemented"
  end

  def startbrowserautopwn
    raise "Not Implemented"
  end

  def error
    @task = Task.find(params[:id])
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(@task.error)}");
      }
    end

  end
end
