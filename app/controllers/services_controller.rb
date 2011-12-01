class ServicesController < ApplicationController

  def exploits
    begin
      @exploits = EvasionDB::AttackModule.all
    rescue
      # handle if no exploits found
      @exploits = []
    end
    @service = Service.find params[:id]
    t = render_to_string :template=>"services/exploits", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end
  end

end
