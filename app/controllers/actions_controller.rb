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

  def attack_host
    FIDIUS::XmlRpcModel.exec_attack_host(params[:host_id])
    render :text=>"ok"
  end

  def reconnaissance
    FIDIUS::XmlRpcModel.exec_reconnaissance_from_host(params[:host_id])
    render :text=>"ok"
  end

  def dialog_closed
    FIDIUS::XmlRpcModel.exec_dialog_closed
    render :text=>"ok"
  end

  def start_file_autopwn
    FIDIUS::XmlRpcModel.exec_start_file_autopwn(params[:tf][:lhost])
    render :text=>"ok"
  end

  def start_browser_autopwn
    FIDIUS::XmlRpcModel.exec_start_browser_autopwn(params[:tf][:lhost])
    render :text=>"ok"
  end

  def update_all
    # reload objects like tasks or host graph, but only if needed
    if FIDIUS::XmlRpcModel.exec_data_changed? == "true"
      render :update do |page|
        page <<%{
          jQuery.ajax('/tasks');
          jQuery.ajax('/hosts/svg_graph');
          jQuery.ajax('/events/fetch_next_event');
        }
      end
    else
      render :text => "nothing to update"
    end
  end
end
