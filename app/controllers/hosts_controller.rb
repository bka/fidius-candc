class HostsController < ApplicationController
  def index
    @hosts = Host.all
  end

  def show
    @host = Host.find(params[:id])
  end

  def new
    @host = Host.new
  end

  def edit
    @host = Host.find(params[:id])
  end

  def create
    @host = Host.new(params[:host])

    if @host.save
      redirect_to(@host, :notice => 'Host was successfully created.')
    else
      render :action => "new"
    end
  end

  def update
    @host = Host.find(params[:id])

    if @host.update_attributes(params[:host])
      redirect_to(@host, :notice => 'Host was successfully updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @host = Host.find(params[:id])
    @host.destroy
    redirect_to(hosts_url)
  end
end
