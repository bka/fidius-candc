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

  def info
    @host = Msf::DBManager::Host.find params[:id]

    a = render_to_string :partial=>"hosts/host_info", :layout => "blank"
    render :update do |page|
      page.replace_html "context-menu", a
    end       
  end

  def svg_graph
    @hosts = Msf::DBManager::Host.all
  end
end
