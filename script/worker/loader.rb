require "yaml"
require 'rubygems'

puts "Loading MsfConfig"
raise "could not load configuration file" unless (MSF_SETTINGS = YAML::parse_file "#{RAILS_ROOT}/config/msf.yml")
puts "Loading DataBase Config"
raise "could not load database configuration file" unless (DB_SETTINGS = YAML.load_file("#{RAILS_ROOT}/config/database.yml")[RAILS_ENV])

PATH_TO_MSF_LIB="#{MSF_SETTINGS.select("/msf_lib").first.value}"

$:.unshift(PATH_TO_MSF_LIB)

require "#{MSF_SETTINGS.select("/subnet_manager_path").first.value}"
require "msf/base"