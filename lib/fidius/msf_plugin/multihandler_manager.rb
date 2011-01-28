module Msf
  class Plugin::MultiHandlerManager < Msf::Plugin
    
    module MultiHandlerManager 
    
      def stop_multihandler jid
       jobs.stop_job jid
      end
      
      def get_running_multihandler
        handlers = []
        jobs.each do |key, value|
          if value.name == "Exploit: multi/handler"
            ctx_datastore = value.ctx[0].datastore
            handlers <<  {:jid => key, :payload =>ctx_datastore["PAYLOAD"], :lport =>ctx_datastore["LPORT"], :lhost => ctx_datastore["LHOST"], :start_time => value.start_time}
          end
        end      
        handlers
      end
    end
    
    def initialize(framework, opts)
      super
      framework.extend(MultiHandlerManager)
    end

	  def cleanup
		  
	  end

		def name
			"Fidius Multi/Handler Manager"
		end

	  def desc
		  "Fidius Extension to manage Background Multi/Handler"
	  end
    
  end

end
