module FIDIUS
  require 'drb'
  require 'pp'

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
      drb_url = YAML::parse_file(File.join RAILS_ROOT, 'config', 'msf.yml').select("/drb_url").first.value
      if drb_url
        drb_url
        DRb.start_service
        worker = DRbObject.new nil, drb_url
        worker.stop
      end
    rescue DRb::DRbConnError
      puts "Halted."
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

