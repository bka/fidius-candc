require 'rubygems'
require "#{RAILS_ROOT}/script/worker/loader"
require "#{RAILS_ROOT}/script/worker/msf_session_event"

require 'drb'

module CommandHandler

  class CommandReceiver

    def autopwn iprange, async = true
      manager = SubnetManager.new @framework, iprange
      if(async)
        thread = Thread.new do
          begin      
            manager.get_sessions
          rescue ::Exception
            puts("problem in session_action: #{$!} #{$!.backtrace}")
          end
        end
      else
        manager.get_sessions
      end
    end

    def nmap iprange, async = true
      manager = SubnetManager.new @framework, iprange
      if(async)
        thread = Thread.new do
          begin      
            manager.run_nmap
          rescue ::Exception
            puts("problem in session_action: #{$!} #{$!.backtrace}")
          end
        end
      else
        manager.run_nmap
      end
    end

    def cmd_session_install sessionID
      if (session = @framework.sessions.get(sessionID))
        if (session.type == "meterpreter")
          return "Install meterpreter on session."
          install_meterpreter(session)
        else
         return "Selected session is not a meterpreter session"
        end
      else
        return "No such session found"
      end
    end

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
end

if not MSF_SETTINGS.select("/drb_url")
  puts "please specify drb_url in msf.yml"
  return
end

DRb.start_service MSF_SETTINGS.select("/drb_url").first.value, CommandHandler::CommandReceiver.new

puts DRb.uri

DRb.thread.join
