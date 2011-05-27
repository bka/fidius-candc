class ConsoleController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.js
    end
  end

  def dialog
    
  end

  def input
    @cmd = params[:cmd]
    @session_id = params[:session_id]

    begin
      if @session_id != nil 
        res = FIDIUS::XmlRpcModel.meterpreter_exec_command @cmd, @session_id
      else
        res = FIDIUS::XmlRpcModel.console_exec_command @cmd
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
