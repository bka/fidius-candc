require 'drb'

class TasksController < ApplicationController

  def initialize
    msf = YAML::load(open(File.join(File.dirname(__FILE__), '..', '..', 'config', 'msf.yml')))
    if not msf['drb_url']
      puts "please specify drb_url in msf.yml"
      return
    end

    DRb.start_service
    @msf_worker = DRbObject.new nil, msf['drb_url']
  end
  def index

  end

  def scan
    @msf_worker.autopwn params[:subnet]
    flash[:notice] = "Scan started"
    redirect_to :root
  end
end
