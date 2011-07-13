class WelcomeController < ApplicationController
  
  def credits
    t = render_to_string 'credits', :layout => false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end    
  end
  
  def documentation
    t = render_to_string 'documentation', :layout => false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end 
  end
  
  def license
  end
  
  def report
    t = render_to_string 'report', :layout => false
    render :update do |page|
      page <<%{
        $('#standard_dialog').html("#{escape_javascript(t)}");
      }
    end
  end

end
