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
    interface_id = FIDIUS::XmlRpcModel.exec_decision_next_host
    inter = Interface.find_by_id(interface_id)
    puts "mark host #{inter}"
    begin
      render :update do |page|
        page <<%{
          mark_host(#{inter.host_id});
        }
      end
    rescue
      render :status=>500,:text=>$!.to_s+"\n"+$!.backtrace[0..7].to_s
    end
  end

  def remove_finished_tasks
    FIDIUS::XmlRpcModel.exec_remove_finished_tasks
    render :nothing => true
  end

  def clean_hosts
    FIDIUS::XmlRpcModel.exec_clean_hosts
    render :text=>"ok"
  end

  def attack_host
    FIDIUS::XmlRpcModel.exec_attack_host(params[:host_id])
    render :text=>"ok"
  end

  def attack_interface
    FIDIUS::XmlRpcModel.exec_attack_interface(params[:interface_id])
    render :text=>"ok"
  end
  
  def attack_service
    FIDIUS::XmlRpcModel.exec_attack_service(params[:service_id])
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

  def clicked_yes
    FIDIUS::XmlRpcModel.exec_dialog_yes
    render :text=>"ok"
  end

  def clicked_no
    FIDIUS::XmlRpcModel.exec_dialog_no
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

  def kill_task
    task_id = params[:id].to_i
    FIDIUS::XmlRpcModel.exec_kill_task(task_id)
    render :text=>"ok"
  end
  
  def single_exploit_host
    host = params["host_id"]
    exploit = params["exploit_id"]
    FIDIUS::XmlRpcModel.exec_single_exploit_host(host, exploit)
    render :text=>"ok"
  end

  def single_exploit_interface
    interface = params["interface_id"]
    exploit = params["exploit_id"]
    FIDIUS::XmlRpcModel.exec_single_exploit_interface(interface, exploit)
    render :text=>"ok"
  end

  def single_exploit_service
    service = params["service_id"]
    exploit = params["exploit_id"]
    FIDIUS::XmlRpcModel.exec_single_exploit_service(service, exploit)
    render :text=>"ok"
  end

  def reset_agent
    FIDIUS::XmlRpcModel.exec_reset_agent
    render :text=>"ok"
  end

  def new_pentest
    FIDIUS::XmlRpcModel.exec_new_pentest
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
