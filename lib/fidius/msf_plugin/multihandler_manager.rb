module Msf
  class Plugin::MultiHandlerManager < Msf::Plugin
    
    module MultiHandlerManager
    
      def start_multihandler options
        begin
          mod = nil
          unless (mod = modules.create("exploit/multi/handler"))
            puts("Failed to initilize exploit/multi/handler")
            return
          end
          options.each_pair do |key, value|
            mod.datastore[key] = value
          end
          mod.datastore['Quiet'] = true
          mod.datastore['RunAsJob'] = true
          cur_thread = Thread.new(mod) do |thread_mod|
            begin
              thread_mod.exploit_simple(mod.datastore)
            rescue ::Exception
              puts "Failed to start #{options[:payload]} Multi/Handler on #{options[:lhost]}"
            end
          end
        rescue ::Interrupt
        raise $!
        rescue ::Exception
          puts(" >> multihandler_manager: exception starting multi/handler #{$!.backtrace}")
        end
        return cur_thread
      end
    
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
