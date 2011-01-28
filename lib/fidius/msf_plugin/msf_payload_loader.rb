module Framework
	module PluginManager
		def load(path, opts = {})
      if (File.exists?(path) or File.exists?(path + ".rb"))
        def_path = path
      else
  			def_path = Msf::Config.plugin_directory + File::SEPARATOR + path
      end
			if (File.exists?(def_path) or File.exists?(def_path + ".rb"))
				super(def_path, opts)
			else
				super
			end
		end
	end
end
