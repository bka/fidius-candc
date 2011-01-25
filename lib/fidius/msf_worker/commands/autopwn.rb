module FIDIUS::MsfWorker::Autopwn
  # Not documentated yet.
  #
  # Call sequence:
  #   cmd_autopwn(:args => [], :task => nil)
  #
  # @param [Array] args  Arguments.
  # @param [Task] task  A Task ActiveRecord.
  FIDIUS::MsfWorker.register_command :autopwn do |options|
    args = options[:args]
    task = options[:task]
    lhost = nil
    Rex::Socket::SwitchBoard.each do |route| 
      route.comm.net.config.each_route do |ipaddr|
        if (IPAddr.new "#{ipaddr.subnet}/#{ipaddr.netmask}").include? IPAddr.new args[0]
          lhost = ipaddr.gateway
        end
      end
    end
    autopwn args[0], lhost, task
  end

private
  def autopwn iprange, lhost, task = nil
    manager = SubnetManager.new @framework, iprange, 1, nil, lhost
    my_ip = get_my_ip iprange
    # tell our prelude fetcher that we want to have all events we generate in
    # prelude from now on
    if FIDIUS::MSF_SETTINGS["match_prelude_logs"] == "true"
      @prelude_fetcher.attack_started
      # let tcpdump watch our traffic
      @tcpdump.start
    end
    manager.run_nmap
    # now stop sniffing traffic
    if FIDIUS::MSF_SETTINGS["match_prelude_logs"] == "true"
      @tcpdump.stop
      # and read out relevant packets most of them should be
      # a result of run_nmap
      @tcpdump.read do |src_ip, src_port, dst_ip, dst_port, payload|
        # we are interested in traffic, that we generated
        if src_ip == my_ip
          PayloadLog.create(
            :exploit => "nmap",
            :payload => payload,
            :src_addr => src_ip,
            :dest_addr => dst_ip,
            :src_port => src_port,
            :dest_port => dst_port,
            :task_id => task.id
          )
        end
      end
    end
    # we do not want to use nmap for autopwn
    s = manager.get_sessions(false)
    if FIDIUS::MSF_SETTINGS["match_prelude_logs"] == "true"
      @prelude_fetcher.get_events(my_ip).each do |ev|
        puts "save prelude event #{ev.id}"
        PreludeLog.create(
          :task_id => task.id,
          :payload => ev.payload,
          :detect_time => ev.detect_time,
          :dest_ip => ev.dest_ip,
          :dest_port => ev.dest_port,
          :src_ip => ev.source_ip,
          :src_port => ev.source_port,
          :text => ev.text,
          :severity => ev.severity,
          :analyzer_model => ev.analyzer_model,
          :ident => ev.id
        )
      end
      puts "saving of events finished"
    end

    # after autopwn finished
    # we have all payload-logs from metasploit
    # and all prelude logs
    # now lets match them against each other for the given task_id
    if task
      if FIDIUS::MSF_SETTINGS["match_prelude_logs"] == "true"
        puts "Matching Payloads against Prelude logs..."
        calculate_matches_between_payloads_and_prelude_logs(task.id)
        puts "Matching done."
      end
    end
    puts "autopwn finished"
  end
end

class FIDIUS::MsfWorker
  include FIDIUS::MsfWorker::Autopwn
end
