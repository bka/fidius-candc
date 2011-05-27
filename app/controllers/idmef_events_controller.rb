class IdmefEventsController < ApplicationController
  def index
    h = EvasionDB::AttackModule.first
    @idmef_events = h.idmef_events
    t = render_to_string :partial=>"idmef_events/idmef_events_full", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end    
  end
end
