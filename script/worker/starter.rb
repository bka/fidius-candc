module FIDIUS
  class Starter
    PID_FILE = File.join RAILS_ROOT, 'tmp', 'pids', 'msf-worker'

    def self.start
      if File.exist? PID_FILE
        begin
          pid = File.read(PID_FILE).to_i
          Process.getpgid pid
          puts "FIDIUS MSF worker already running as Process #{pid}"
          return
        rescue
          File.delete PID_FILE
          puts "No process. Deleted PID file and starting..."
        end
      end
      puts "ruby script/runner script/worker/msf-worker.rb -e #{RAILS_ENV} &"
      system "ruby script/runner script/worker/msf-worker.rb -e #{RAILS_ENV} &"
    end

    def self.stop
      if File.exist? PID_FILE
        pid = File.read(PID_FILE).to_i
        Process.kill("TERM", pid)
        Process.kill("INT", pid)
        File.delete PID_FILE
        puts "FIDIUS MSF worker stopped."
      else
        puts "No process. FIDIUS MSF worker not running."
      end
    end

    def self.restart
      stop
      start
    end
  end
end

# invoked by script/runner, invoked by script/msf-worker.
# see there for usage.
FIDIUS::Starter.send ARGV[0].to_sym

