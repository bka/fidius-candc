require "yaml"
require 'rubygems' # XXX: really?

# 
# XXX: too many constants?
# 

puts "Loading MSF config"
MSF_SETTINGS = YAML::parse_file File.join RAILS_ROOT, 'config', 'msf.yml'
raise "could not load config/msf.yml" unless MSF_SETTINGS

puts "Loading database config"
DB_SETTINGS = YAML.load_file(File.join RAILS_ROOT, 'config', 'database.yml')[RAILS_ENV]
raise "could not load config/database.yml" unless DB_SETTINGS

PATH_TO_MSF_LIB = File.join MSF_SETTINGS.select("/msf_path").first.value, 'lib'

$:.unshift(PATH_TO_MSF_LIB)

require MSF_SETTINGS.select("/subnet_manager_path").first.value
require "msf/base"
