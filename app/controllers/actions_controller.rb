class ActionsController < ApplicationController
  def scan
    FIDIUS::XmlRpcModel.exec_action_scan(params[:tf][:iprange])
    render :text=>"ok"
  end

  def rate_host
    puts params[:host_id]+","+params[:rating]
    FIDIUS::XmlRpcModel.exec_rate_host(params[:host_id],params[:rating])
    render :text=>"ok"
  end

  def next_target
    begin
      render :text=>FIDIUS::XmlRpcModel.exec_decision_next
    rescue
      render :status=>500,:text=>$!.to_s+"\n"+$!.backtrace[0..7].to_s
    end
  end

  def clean_hosts
    FIDIUS::XmlRpcModel.exec_clean_hosts
    render :text=>"ok"
  end
end
