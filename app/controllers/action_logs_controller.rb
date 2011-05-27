class ActionLogsController < ApplicationController
  def index
    @action_logs = ActionLog.all

    t = render_to_string :partial=>"action_logs/table", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end    
  end
end
