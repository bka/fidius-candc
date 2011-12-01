# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
CommandAndControl::Application.initialize!


# All AR findmethods will be transfered over rpc-xml
# if you want to use direct connection to your local database
# set this to false and edit your database.yml to point to
# your database (the same which is used in fidius-core)

if ENV['RAILS_ENV'] == "test"
  USE_RPC_FOR_MODELS = true
else
  USE_RPC_FOR_MODELS = false
end
