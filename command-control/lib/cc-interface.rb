module CommandControl
  class ServletInterface
    ERROR_RESPONSE   = [501, { "Content-Type" => "text/plain" }, "FIDIUS CC: 501, Not Implemented."]
    
  private
    #
    # Delegates incoming requests to method do_XYZ (with XYZ = HTTP method)
    #
    def handle_method request
      return do_GET(request)     if request.get?
      return do_HEAD(request)    if request.head?
      return do_POST(request)    if request.post?
      return do_PUT(request)     if request.put?
      return do_OPTIONS(request) if request.options?
      return do_DELETE(request)  if request.delete?
      ERROR_RESPONSE
    end
    
    %w[GET HEAD POST PUT OPTIONS DELETE].each do |method|
      m = "do_#{method}"
      define_method m.to_sym, Proc.new { puts "huhu"; return ERROR_RESPONSE }
    end
  end
end
