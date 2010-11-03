class HostsController < ApplicationController
  def index
    @hosts = Msf::DBManager::Host.all
  end

  def show
    @host = Msf::DBManager::Host.find params[:id]
  end
end
