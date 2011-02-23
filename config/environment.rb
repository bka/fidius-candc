# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
CommandAndControl::Application.initialize!

# unfortunately json-addon has to be loaded after activesupport
require File.join("#{RAILS_ROOT}","config","initializers","json_symbol_addon.rb")
