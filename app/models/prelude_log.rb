class PreludeLog < ActiveRecord::Base
  def payload
    return [] if self[:payload] == nil
    self[:payload]
  end

  def get_payloads_logs
    require 'rex'
    result = Array.new
    if payload.size > 0
      event_payload = Rex::Text.to_hex(payload).gsub("\\x","")
      PayloadLog.find(:all,:conditions=>{:task_id=>task_id}).each do |log|
        # lets find the payload of the prelude event
        # in one of the logged payloads
        log_payload = Rex::Text.to_hex(log.payload).gsub("\\x","")
        str = log_payload[event_payload]
        index = -1
        if str != nil
          index = 1
        end
        #index = ShiftOr.find(log_payload,event_payload)
        if index >= 0
          result << {:obj=>log,:index=>index}
        end
      end    
    end
    return result
  end
end
