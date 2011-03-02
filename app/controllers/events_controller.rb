class EventsController < ApplicationController
  include FaceboxHelper
  def fetch_next_event
    @event = Event.fetch_next
    if @event
      @title = @event.title
      @message = @event.message
      render :update do |page|
        page <<%{
          $( "#dialog" ).dialog();
        }
      end       
      
      #render_to_facebox(:template => "events/fetch_next_event")
    else
      render :text => ""
    end
  end

  def user_response
    puts params[:response]
    close_facebox
  end
end
