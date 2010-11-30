class PayloadLogsController < ApplicationController
  def show
    require 'rex'
    @payload_log = PayloadLog.find params[:id]
    @payload_hex = Rex::Text.to_hex_dump(@payload_log.payload).gsub("\n", '<br />')
  end
end
