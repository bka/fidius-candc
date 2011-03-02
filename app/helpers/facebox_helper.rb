module FaceboxHelper
  def facebox_includes
    return "<link href=\"/facebox/facebox.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\" />
    <script src=\"/facebox/facebox.js\" type=\"text/javascript\"></script>"
  end

  def link_to_facebox(name, options = {})
    link_to name, options, :rel => "facebox"
  end

  def close_facebox
    render :update do |page|
      page << "facebox.close();"
    end
  end  

  def render_to_facebox( options = {} )
    l = options.delete(:layout) { false }

    if options[:action]
      s = render_to_string(:action => options[:action], :layout => l)
    elsif options[:template]
      s = render_to_string(:template => options[:template], :layout => l)
    elsif !options[:partial] && !options[:html]
      s = render_to_string(:layout => l)
    end
    
    render :update do |page|
      if options[:action]
        page << "facebox.reveal('#{s.to_json}',null);"
      elsif options[:template]
        page << 'facebox.reveal('+s.to_json+',null);'
      elsif options[:partial]
        page << "facebox.reveal('#{(render :partial => options[:partial]).to_json}',null);"
      elsif options[:html]
        page << "facebox.reveal('#{options[:html].to_json}',null);"
      else
        page << "facebox.reveal(#{s.to_json},null);"
      end
      
      if options[:msg]
        #page << "jQuery('#facebox .content').prepend('<div class=\"message\">#{options[:msg]}</div>')"
        page << "facebox.reveal('<div class=\"message\">#{options[:msg]}</div>', null)";
      end
          
      yield(page) if block_given?
      
    end
  end
end
