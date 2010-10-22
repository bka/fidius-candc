CC_PID_FILE = File.join(File.dirname(__FILE__), 'command-control', 'cc.pid')

def call_rake(task, rakefile = __FILE__)
  system "/usr/bin/rake #{task} -s -f #{rakefile} 2>&1 >> #{File.join(File.dirname(__FILE__), 'log', "rake-#{task}.log")} &"
end

### defs  above ###
### tasks below ###

desc "Default task. Starts a CC server and does other things..."
task :default => [CC_PID_FILE]

file CC_PID_FILE do
  call_rake :start_cc
end

desc "Starts the CC server."
task :start_cc do
  require './command-control/cc.rb'
  CommandControl.boot  
end

desc "Stops the CC server"
task :stop_cc do
  if File.exists? CC_PID_FILE
    pid = File.read(CC_PID_FILE).strip
    sh "kill -15 #{pid}" if pid =~ /\d+/
    FileUtils.rm CC_PID_FILE
  end
end

