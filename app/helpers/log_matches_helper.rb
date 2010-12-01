module LogMatchesHelper

  def calculate_matches_between_payloads_and_prelude_logs(task_id)
    require 'rex'
    PreludeLog.find_all_by_task_id(task_id).each do |prelude_log|
      event_payload = nil
      if prelude_log.payload.size > 0
        payload = prelude_log.payload
        event_payload = Rex::Text.to_hex(payload).gsub("\\x","")
      end

      PayloadLog.find(:all, :conditions => { :task_id => task_id,:prelude_log_id => nil }).each do |log|
        str = nil
        if event_payload != nil
          # lets find the payload of the prelude event
          # in one of the logged payloads
          log_payload = Rex::Text.to_hex(log.payload).gsub("\\x","")
          str = log_payload[event_payload]
        end

        next if str.nil? && log.exploit != "nmap"
        if log.exploit == "nmap"
          if log.dest_port.to_i == 5800
            #puts "Here we are: #{log.inspect}"
            puts "#{prelude_log.text}(#{prelude_log.id}):#{prelude_log.dest_port.to_i} != #{log.dest_port.to_i} || #{prelude_log.src_port.to_i} != #{log.src_port.to_i} || #{prelude_log.payload.size} > 0"
          end
          next if prelude_log.dest_port.to_i != log.dest_port.to_i || prelude_log.src_port.to_i != log.src_port.to_i #|| prelude_log.payload.size > 0
          if log.dest_port.to_i == 5800
            puts "not skipped"
          end
        end
        log.prelude_log_id = prelude_log.id
        log.save
        break
      end
    end

  end

end
