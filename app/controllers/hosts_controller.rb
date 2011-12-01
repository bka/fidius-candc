# -*- coding: utf-8 -*-
class HostsController < ApplicationController
  def index
    redirect_to :action=>:graph
  end

  def show
    @host = Host.find params[:id]
  end

  def graph

  end

  def nvd_entries
    @show_nvd    = true
    @host        = Host.find params[:id]
    @nvd_entries = @host.nvd_entries

    render :update do |page|
      page <<%{
        $('#nvd-entries').replaceWith("#{escape_javascript(render(:partial =>'hosts/nvd_entries'))}")
      }
    end
  end

  def clear
    raise "destroy all hosts is not implemented"
    redirect_to :hosts
  end

  def info
    @host = Host.find params[:id]
    a = render_to_string :partial=>"hosts/host_info", :layout => false
    b = render_to_string :partial=>"hosts/host_commands", :layout => false

    render :update do |page|
      page <<%{
        $('#context-menu').html("#{escape_javascript(a+b)}");
      }
    end
  end

  def svg_graph
    @hosts = Host.all
  end

  def status
    render :text => "KI sagt"
  end

  def exploits
    begin
      #Needs evasiondb 0.0.2 first
      @exploits = EvasionDB::AttackModule.all
    rescue
      # handle if no exploits found
      @exploits = []
    end
    @host = Host.find params[:id]
    t = render_to_string :template=>"hosts/exploits", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end
  end

  def idmef_events
    # Dummy Ansicht fuer den Projekttag
    @idmef_events = []
    host = Host.find(params[:id])

    if host.os_name == "Windows"
      @idmef_events << EvasionDB::IdmefEvent.new(:dest_port => 445, :src_port => 53827, :text => "ET ATTACK_RESPONSE Rothenburg Shellcode", :analyzer_model => "Prelude-Manager", :severity => "high")
      @idmef_events << EvasionDB::IdmefEvent.new(:dest_port => 445, :src_port => 53827, :text => "ET EXPLOIT METASPLOIT BSD Reverse shell (PexFnstenvMov Encoded 2)", :analyzer_model => "Prelude-Manager", :severity => "high")
      @idmef_events << EvasionDB::IdmefEvent.new(:dest_port => 445, :src_port => 53827, :text => "ET EXPLOIT METASPLOIT BSD Reverse shell (PexFnstenvSub Encoded 2)", :analyzer_model => "Prelude-Manager", :severity => "high")
      @idmef_events << EvasionDB::IdmefEvent.new(:dest_port => 445, :src_port => 53827, :text => "ET ATTACK_RESPONSE Rothenburg Shellcode", :analyzer_model => "Prelude-Manager", :severity => "high")
      @idmef_events << EvasionDB::IdmefEvent.new(:dest_port => 445, :src_port => 53827, :text => "ET EXPLOIT METASPLOIT BSD Reverse shell (PexFnstenvMov Encoded 2)", :analyzer_model => "Prelude-Manager", :severity => "high")
      @idmef_events << EvasionDB::IdmefEvent.new(:dest_port => 445, :src_port => 53827, :text => "ET EXPLOIT METASPLOIT BSD Reverse shell (PexFnstenvSub Encoded 2)", :analyzer_model => "Prelude-Manager", :severity => "high")
      @idmef_events << EvasionDB::IdmefEvent.new(:dest_port => 3660, :src_port => 4444, :text => "ET POLICY PE EXE or DLL Windows file download", :analyzer_model => "Prelude-Manager", :severity => "high")
      @idmef_events << EvasionDB::IdmefEvent.new(:dest_port => 3660, :src_port => 4444, :text => "ET POLICY PE EXE or DLL Windows file download", :analyzer_model => "Prelude-Manager", :severity => "high")
    end

    t = render_to_string :partial=>"idmef_events/idmef_events_full", :layout=>false, :locals=>{:idmef_events=>@idmef_events}
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end
  end

  def idmef_event_groups
    @idmef_event_groups = []
    host = Host.find(params[:id])

    finished_tasks_for_host = Task.find_all_by_name_and_completed("Attack #{host.name}", 't')
    task_time = Time.now
    unless finished_tasks_for_host.empty?
      task_time = finished_tasks_for_host.last.updated_at
    end

    @current_host = host.id
    if host.os_name == "Windows"
      @idmef_event_groups << IdmefEventGroup.new(:title=>"Exploit Windows",:time=>task_time,:idmef_count=>8)
    else
      @idmef_event_groups << IdmefEventGroup.new(:title=>"Exploit Linux",:time=>task_time,:idmef_count=>0)
    end

    #@idmef_event_groups << IdmefEventGroup.new(:title=>"Nmap Scan",:time=>Time.now,:idmef_count=>1)
    render :template => "hosts/idmef_event_groups", :layout=>false
  end

  def processes
    @host = Host.find params[:id]
    render :template => "hosts/processes", :layout=>false
  end

end
