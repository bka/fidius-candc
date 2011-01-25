class TerminalsController < ApplicationController
  include DrbHelper

  def index
    @session_id = params[:session_id]
    if @session_id != nil
      @session_param = "?session_id=#{@session_id}"
    end  
    render :template => "terminals/index"
  end


  def send_cmd
    @cmd = params[:cmd]
    @session_id = params[:session_id]

    begin
      if @session_id != nil 
        res = get_msf_worker.cmd_send_to_msfsession @cmd, @session_id
      else
        res = get_msf_worker.cmd_send_to_terminal @cmd
      end
    rescue
      res = $!.to_s
    end
    res = res.gsub("\\","\\\\\\")
    puts "result is: #{res}"
    render :update do |page|
      res.to_s.split("\n").each do |line|
        page << "term.write(\"#{line}\");term.newLine();"
      end
    end           
  end
end
