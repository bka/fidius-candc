def start
  if File.exist?("#{RAILS_ROOT}/tmp/pids/msf-worker")
      begin
        pid = File.new("#{RAILS_ROOT}/tmp/pids/#{name}","r").read.to_i
        Process.getpgid pid
        puts "Msf-Worker already running as Process #{pid}"
        return
      rescue
        File.delete("#{RAILS_ROOT}/tmp/pids/msf-worker")
        puts "no process delete pid file and start"
      end
  end
  system("ruby script/runner script/worker/msf-worker.rb -e #{RAILS_ENV} &")      
end

def stop
  if File.exist?("#{RAILS_ROOT}/tmp/pids/msf-worker")
    pid = File.new("#{RAILS_ROOT}/tmp/pids/msf-worker","r").read.to_i
    Process.kill("INT",pid)
    puts "Msf-Worker stopped"
  else
    puts "No Process Msf-Worker running"
  end
end

def restart
  stop
  start
end

if ["start","stop","restart"].member?(ARGV[0])
  if ARGV[0] == "start"
    start
  end
  if ARGV[0] == "stop"
    stop
  end
  if ARGV[0] == "restart"
    restart
  end

else
  puts "please use \"ruby script/workers start|stop|restart\""
end
