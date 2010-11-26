class PreludeLogsController < ApplicationController
  def index

  end

  def show
    @payload_log = PreludeLog.find params[:id]
    @payload_hex = Rex::Text.to_hex(@payload_log.payload).gsub("\n", '<br />').gsub('\\x', '')
  end
end
