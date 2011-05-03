module FIDIUS::RpcCommands
  class FIDIUS::XmlRpcModel < ActiveRecord::Base
    class << self
      def exec_action_scan(iprange)
        rpc_request("action.scan",iprange)  
      end

      def exec_dialog_closed
        rpc_request("meta.dialog_closed")
      end

      def exec_data_changed?
        rpc_request("meta.data_changed?")
      end

      def exec_attack_host(host_id)
        rpc_request("action.attack_host",host_id)
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
        rpc_request("action.browser_autopwn.start",lhost)
      end

      def exec_start_file_autopwn(lhost)
        rpc_request("action.file_autopwn.start",lhost)
      end
        
    end #class self
  end #class FIDIUS::XmlRpcModel
end #module FIDIUS::RpcCommands
