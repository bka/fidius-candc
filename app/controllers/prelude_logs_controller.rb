class PreludeLogsController < ApplicationController
  def index

  end

  def show
    @log = PreludeLog.find params[:id]
    @payload_hex = Rex::Text.to_hex(@log.payload).gsub("\n","<br>")
  end
end
