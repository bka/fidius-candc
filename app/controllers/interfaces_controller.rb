class InterfacesController < ApplicationController
  def exploits
    begin
      @exploits = EvasionDB::AttackModule.all
    rescue
      # handle if no exploits found
      @exploits = []
    end
    @interface = Interface.find params[:id]
    t = render_to_string :template=>"interfaces/exploits", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end
  end
end
