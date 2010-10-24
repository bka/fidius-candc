CC_PID_FILE = File.join(File.dirname(__FILE__), 'command-control', 'cc.pid')

### defs  above ###
### tasks below ###

desc "Default task. Remembers you to start the command&control server"
task :default => [CC_PID_FILE]

file CC_PID_FILE do
  raise "Start your command&control server!"
end

