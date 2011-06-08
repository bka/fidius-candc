module FIDIUS::RpcCommands
  class FIDIUS::XmlRpcModel < ActiveRecord::Base
    class << self
      def exec_action_scan(iprange)
        rpc_request("action.scan",iprange)  
      end

      def exec_dialog_closed
        rpc_request("meta.dialog_closed")
      end

      def exec_dialog_yes
        rpc_request("meta.dialog_yes")
      end

      def exec_dialog_no
        rpc_request("meta.dialog_no")
      end

      def exec_data_changed?
        rpc_request("meta.data_changed?")
      end

      def exec_attack_host(host_id)
        rpc_request("action.attack_host",host_id)
      end

      def exec_reconnaissance_from_host(host_id)
        rpc_request("action.reconnaissance",host_id)
      end

      def exec_decision_next
        rpc_request("decision.nn.train","DOESNTMATTER")
        rpc_request("decision.nn.next","DOESNMATTER")
      end

      def exec_clean_hosts
        rpc_request("model.clean_hosts","DOESNTMATTER")
      end

      def exec_rate_host(host_id, rating)
        rpc_request("action.rate_host",host_id,rating)
      end

      def exec_start_browser_autopwn(lhost)
        rpc_request("action.browser_autopwn_start",lhost)
      end

      def exec_start_file_autopwn(lhost)
        rpc_request("action.file_autopwn_start",lhost)
      end

      def exec_remove_finished_tasks
        rpc_request("meta.remove_finished_tasks")
      end

      def exec_kill_task(task_id)
        rpc_request("meta.kill_task", task_id)
      end
      
      def exec_single_exploit(host_id, exploit_id)
        rpc_request("action.single_exploit", host_id, exploit_id)
      end      

      def exec_next_action
        rpc_request("meta.next_action")
      end

      def exec_new_pentest
        rpc_request("meta.new_pentest")
      end

      def console_exec_command(cmd)
        return "JO WURST #{rand(5023423)}"
      end

      def exec_start_ki
        rpc_request("meta.set_active",true)
      end

      def exec_stop_ki
        rpc_request("meta.set_active",false)
      end

      def meterpreter_exec_command(cmd,session_id)
        return "JO Metepreter #{rand(5023423)}"
      end
        
    end #class self
  end #class FIDIUS::XmlRpcModel
end #module FIDIUS::RpcCommands
