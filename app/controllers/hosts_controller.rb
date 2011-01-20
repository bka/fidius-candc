class HostsController < ApplicationController
  def index
    @hosts = Msf::DBManager::Host.all
    redirect_to :action=>:graph
  end

  def show
    @host = Msf::DBManager::Host.find params[:id]
  end

  def graph

  end
  
  def nvd_entries
    @show_nvd    = true
    @host        = Msf::DBManager::Host.find params[:id]
    @nvd_entries = @host.nvd_entries
    
    render :partial => "hosts/nvd_entries"
  end

  def clear
    Msf::DBManager::Host.destroy_all
    redirect_to :hosts
  end

  def info
    @host = Msf::DBManager::Host.find params[:id]
    a = render_to_string :partial=>"hosts/host_info", :layout => "blank"
    b = render_to_string :partial=>"hosts/host_commands", :layout => "blank"
    render :update do |page|
      page.replace_html "context-menu", a+b
    end       
  end

  def svg_graph
    @hosts = Msf::DBManager::Host.all
  end

  def destroy
    @host = Msf::DBManager::Host.find params[:id]
    @host.destroy
    redirect_to :hosts
  end
end
