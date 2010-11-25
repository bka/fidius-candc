class PayloadLogsController < ApplicationController
  def show
    require 'rex'
    @payload_log = PayloadLog.find params[:id]
    @payload_hex = Rex::Text.to_hex(@payload_log.payload).gsub("\n", '<br />').gsub('\\x', '')
  end
end
