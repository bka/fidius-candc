class EventsController < ApplicationController
  def fetch_next_event
    @dialog = UserDialog.fetch_next
    if @dialog
      marked_host_id = -1
      if @dialog.dialog_type == UserDialog::DIALOG_TYPE_YES_NO
        t = render_to_string :template => "events/yes_no_dialog", :layout=>false
      else
        t = render_to_string :template => "events/dialog", :layout=>false
      end
      if @dialog.host_id
        marked_host_id = @dialog.host_id
      end

      render :update do |page|
        page <<%{
          $('#event_dialog_placeholder').html("#{escape_javascript(t)}");
           mark_host(#{marked_host_id});
        }
      end
    else
      render :text => ""
    end
  end

  def user_response
    close_facebox
  end
end
