class ActionsController < ApplicationController
  def scan
    FIDIUS::XmlRpcModel.exec_action_scan
    render :text=>"ok"
  end

  def next_target
    render :text=>FIDIUS::XmlRpcModel.exec_decision_next
  end

  def clean_hosts
    FIDIUS::XmlRpcModel.exec_clean_hosts
    render :text=>"ok"
  end
end
