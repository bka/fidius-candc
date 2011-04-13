class HostsController < ApplicationController
  def index
    redirect_to :action=>:graph
  end

  def show
    @host = Host.find params[:id]
  end

  def graph

  end
  
  def nvd_entries
    @show_nvd    = true
    @host        = Host.find params[:id]
    @nvd_entries = @host.nvd_entries
    
    render :update do |page|
      page <<%{
        $('#nvd-entries').replaceWith("#{escape_javascript(render(:partial =>'hosts/nvd_entries'))}")
      }
    end
  end

  def clear
    raise "destroy all hosts is not implemented"
    redirect_to :hosts
  end

  def info
    @host = Host.find params[:id]
    a = render_to_string :partial=>"hosts/host_info", :layout => false
    b = render_to_string :partial=>"hosts/host_commands", :layout => false
    #  page.replace_html "context-menu", a+b
    render :update do |page|
      page <<%{
        $('#context-menu').html("#{escape_javascript(a+b)}")
      }
    end       
  end

  def svg_graph
    @hosts = Host.all
  end

  def status
    render :text => "KI sagt"
  end

  def exploits
    @exploits = EvasionDB::AttackModule.all
    @host = Host.find params[:id]
    t = render_to_string :template=>"hosts/exploits", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end
  end

end
