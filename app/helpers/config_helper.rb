module ConfigHelper
  def throw_exception_if_empty value, cyml
    raise Exception.new("config value #{value} does not exist") if cyml[value].to_s == ""
  end

  def throw_exception_if_not_valid_file path, cyml
    raise Exception.new("File #{path} does not exist") if File.file?(path)
  end

  def throw_exception_if_not_valid_directory path, cyml
    raise Exception.new("Directory #{path} does not exist") if File.directory?(path)
  end

  def check_config
    msf = YAML::load(open(File.join(RAILS_ROOT,'config', 'msf.yml')))
    raise Exception.new("Invalid msf.yml. Pleas check.") if !msf
    throw_exception_if_empty("msf_path",msf)
    throw_exception_if_empty("subnet_manager_path",msf)
    #throw_exception_if_empty("cve_db",msf)

    throw_exception_if_not_valid_directory("msf_path",msf)
    throw_exception_if_not_valid_file("subnet_manager_path",msf)
    #throw_exception_if_not_valid_directory("cve_db",msf)
    throw_exception_if_empty("drb_url",msf)
  end
end
