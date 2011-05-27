class KnowledgeController < ApplicationController
  def index
    begin
      @exploits = EvasionDB::AttackModule.all
    rescue
      # handle if no exploits found
      @exploits = []
    end

    t = render_to_string :template=>"knowledge/index", :layout=>false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end
  end
end
