class HostsController < ApplicationController
  def index
    @hosts = Host.all
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
    
    render :partial => "hosts/nvd_entries"
  end

  def clear
    raise "destroy all hosts is not implemented"
    redirect_to :hosts
  end

  def info
    @host = Host.find params[:id]
    a = render_to_string :partial=>"hosts/host_info", :layout => "blank"
    b = render_to_string :partial=>"hosts/host_commands", :layout => "blank"
    render :update do |page|
      page.replace_html "context-menu", a+b
    end       
  end

  def svg_graph
    @hosts = Host.all
  end

end
