class IdmefEventsController < ApplicationController
  def index
    h = EvasionDB::AttackModule.first
    @idmef_event_groups = []
    @idmef_event_groups << IdmefEventGroup.new(:title=>"Exploit Windows",:time=>Time.now,:idmef_count=>4)
    @idmef_event_groups << IdmefEventGroup.new(:title=>"Nmap Scan",:time=>Time.now,:idmef_count=>1)

    t = render_to_string :partial=>"idmef_events/idmef_event_groups", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end
  end
end
