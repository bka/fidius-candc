class MultihandlerController < ApplicationController

  def show
    @worker = get_msf_worker
    @multihandlers = @worker.cmd_get_running_multihandler
  end

end
