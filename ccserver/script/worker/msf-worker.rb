require "yaml"
require 'rubygems'
require 'eventmachine'


puts "Loading MsfConfig"
raise "could not load configuration file" unless (MSF_SETTINGS = YAML::parse_file "#{RAILS_ROOT}/config/msf.yml")
puts "Loading DataBase Config"
raise "could not load database configuration file" unless (DB_SETTINGS = YAML.load_file("#{RAILS_ROOT}/config/database.yml")[RAILS_ENV])

PATH_TO_MSF_LIB="#{MSF_SETTINGS.select("/msf_lib").first.value}"

$:.unshift(PATH_TO_MSF_LIB)

require "#{MSF_SETTINGS.select("/subnet_manager_path").first.value}"
require "msf/base"
# require "rex"

def init_ipc
  system "mkfifo commands" unless File.exists?("commands") and File.pipe?("commands")
  input = open("commands", "r+") # the r+ means we don't block
  conn = EM.watch input, CommandHandler
  conn.notify_readable = true
end

module CommandHandler
  
  def initialize
    puts "Initialize Framework..."
    @framework =  Msf::Simple::Framework.create
    puts "done."
    connect_db
    @framework.db.exploited_hosts.delete_all
  end
  
  def notify_readable
    while (cmd = @io.readline)
      parse_command cmd
    end
  rescue EOFError
    detach
  end

  def unbind
    EM.next_tick do
      # socket is detached from the eventloop, but still open
      data = @io.read
    end
  end
  
  def parse_command _cmd
    cmd = _cmd.split
    if commands.has_key? cmd[0].to_s
      send("cmd_#{cmd[0]}".to_sym, cmd[1..-1])
    else
      raise "Unknown Command"
    end
  end

  def commands
    base = {
        "autopwn" => "Starts Autopwning",
        "nmap" => "Starts a Nmap Scan"
      }
    more = {
          "cmd3" => "cmd",
          "cmd4" => "cmd"
      }
    base.merge(more)
  end
  
  def cmd_autopwn args
    manager = SubnetManager.new @framework, args[0]
    manager.get_sessions
  end
  
  def cmd_nmap args
    manager = SubnetManager.new @framework, args[0]
    manager.run_nmap
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
end

EventMachine::run do
  puts "start EM"
  init_ipc
end
