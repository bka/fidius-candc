module CommandControl
  VERSION = '0.1.0'

  class Servlet < ServletInterface  
    #
    # Handles incoming requests.
    #
    def call env
      @env = env
      puts "#{Time.now}: #{@env["REMOTE_ADDR"]} #{@env["REQUEST_METHOD"]} #{@env["REQUEST_URI"]}"
      request = Rack::Request.new env
      return handle_method(request) || http_not_found("Only HTTP-GET supported.")
    end

    def self.signature
      "FIDIUS CC #{VERSION}, #{Time.now}.\n"
    end
    
    def signature
      self.signature << "#{@env["SERVER_SOFTWARE"]} at #{@env["SERVER_NAME"]}:#{@env["SERVER_PORT"]}\n"
    end

  private
    def do_GET req
      http_not_found if @env['REQUEST_URI'] =~ /^\/favicon.ico/
      http_ok(signature, "Content-Type" => "text/plain")
    end
    
    def http_ok body, header = { "Content-Type" => "text/html" }
      [200, header, body]
    end

    def http_not_found msg = nil
      puts "  404 Not Found." # logger!
      body   = [ "404: File Not Found." ]
      body   << "\n\n#{msg}" if msg
      body   << "\n\n-- \n#{signature}"
      header = { "Content-Type" => "text/plain" }
      [404, header, body]
    end
  end
end
