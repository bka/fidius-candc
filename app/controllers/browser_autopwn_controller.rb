class BrowserAutopwnController < ApplicationController
  def index
    worker = get_msf_worker
    @interfaces = get_msf_worker.cmd_get_interfaces
  end
end
