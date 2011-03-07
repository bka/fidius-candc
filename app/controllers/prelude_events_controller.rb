class PreludeEventsController < ApplicationController
  def index
    @prelude_events = PreludeEvent.all
    t = render_to_string :template=>"prelude_events/index", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end
  end
end
