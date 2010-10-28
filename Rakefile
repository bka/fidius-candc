#!/usr/bin/env rake

require 'rake/clean'

CC          = 'command-control'
CC_FILE     = File.join(File.dirname(__FILE__), CC, "cc.rb")
CC_LOG_FILE = File.join(File.dirname(__FILE__), CC, "cc.log")
CC_PID_FILE = File.join(File.dirname(__FILE__), CC, "cc.pid")

%w[pid log sqlite].each do |f|
  CLOBBER.include File.join(CC, "*.#{f}")
end


desc "Default task (starts the CC server)."
task :default => [CC_PID_FILE]

desc "Starts the CC server (in background)."
file CC_PID_FILE do
  unless Process.uid == 0
    puts "[FIDIUS CC] You need to be root!"
    exit 1
  end
  system "nohup ruby #{CC_FILE} 2>&1 >> #{CC_LOG_FILE} &"
end

desc "Stops the CC server."
task :stop_cc do
  begin
    pid = File.read(CC_PID_FILE).strip
    sh "kill -TERM #{pid}"
    File.unlink CC_PID_FILE
    puts "[FIDIUS CC] Server stopped."
  rescue Errno::ENOENT
    puts "[FIDIUS CC] Server not running."
  rescue RuntimeError
    puts "[FIDIUS CC] Server is not running (given PID in #{CC_PID_FILE})."
  end
end

