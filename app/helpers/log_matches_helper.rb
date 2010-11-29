module LogMatchesHelper
  def calculate_matches_between_payloads_and_prelude_logs(task_id)
    require 'rex'
    PreludeLog.find_all_by_task_id(task_id).each do |prelude_log|
      puts "#{prelude_log}"
      payload = prelude_log.payload
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
          if index >= 0
            puts "SET ID NEW: "
            log.prelude_log_id = prelude_log.id
            log.save
          end
        end    
      end
    end
  end
end