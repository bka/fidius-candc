class EventsController < ApplicationController
  def fetch_next_event
    @dialog = UserDialog.fetch_next
    if @dialog
      if @dialog.dialog_type == UserDialog::DIALOG_TYPE_YES_NO
        t = render_to_string :template => "events/yes_no_dialog", :layout=>false     
      else
        t = render_to_string :template => "events/dialog", :layout=>false
      end
      render :update do |page|
        page <<%{
          $('#event_dialog_placeholder').html("#{escape_javascript(t)}");
          $( "a", ".dialog_actions" ).button();
		      $( "a", ".dialog_actions" ).click(function() { alert("deine mudder"); });
        }
      end
    else
      render :text => ""
    end
  end

  def user_response
    puts params[:response]
    close_facebox
  end
end
