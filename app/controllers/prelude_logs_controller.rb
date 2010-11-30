class PreludeLogsController < ApplicationController
  def index

  end

  def show
    require 'rex'
    @payload_log = PreludeLog.find params[:id]
    @payload_hex = Rex::Text.to_hex_dump(@payload_log.payload).gsub("\n", '<br />')
  end
end
