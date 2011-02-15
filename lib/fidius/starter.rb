#!/usr/bin/env script/runner

require 'drb'
require 'fidius/msf_worker'

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
      FIDIUS::Boot.new
    end

    def self.stop
      if drb_url = YAML.load_file(File.join RAILS_ROOT, 'config', 'msf.yml')['drb_url']
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

if %w[start stop restart].include? ARGV[0]
  FIDIUS::Starter.send ARGV[0].to_sym
else
  puts "Usage:\n\truby script/runner lib/fidius/starter.rb start|stop|restart [ENVIROMENT]"
end


