class PreludeEventFetcher
  def initialize
    @start_time = nil
  end

  def attack_started
    a = Prelude::Alert.find(:first,:joins => [:detect_time],:order=>"time DESC")
    last_event = PreludeEvent.new(a)
    @start_time = last_event.detect_time
  end

  def get_events(src_ip=nil)
    raise Exception.new("Call attack_started before get_events") if @start_time == nil
    res = Array.new
    events = Prelude::Alert.find(:all,:joins => [:detect_time],:order=>"time DESC",:conditions=>["time > :d",{:d => @start_time}])
    events.each do |event|
      ev = PreludeEvent.new(event)
      puts ev.inspect
      if src_ip != nil
        if ev.source_ip == src_ip
          res << ev
        end
      else
        res << ev
      end
    end
    @start_time =  nil
    return res
  end
end

#pef = PreludeEventFetch.new
#pef.attack_start
#pef.get_events("10.0.0.101").inspect
