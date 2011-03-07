module FIDIUS::RpcCommands
  class FIDIUS::XmlRpcModel < ActiveRecord::Base
    class << self
      def exec_action_scan(iprange)
        rpc_request("action.scan",iprange)  
      end

      def exec_data_changed?
        rpc_request("meta.data_changed?")
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


        
    end #class self
  end #class FIDIUS::XmlRpcModel
end #module FIDIUS::RpcCommands
