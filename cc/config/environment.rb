# Load the rails application
require File.expand_path('../application', __FILE__)

yaml = YAML::load(open(File.join(File.dirname(__FILE__), 'msf.yml')))
LOCAL_MSF_SVN_CHECKOUT = yaml['msf_lib']

Dir.new(File.join(LOCAL_MSF_SVN_CHECKOUT, 'lib', 'msf', 'core')) do
  require File.join(LOCAL_MSF_SVN_CHECKOUT, 'lib', 'msf', 'core', 'db.rb')
  Dir.glob(File.join(LOCAL_MSF_SVN_CHECKOUT, 'lib', 'msf', 'core', 'model', '*.rb')).each do |rb|
    require rb
  end
end

# Initialize the rails application
Cc::Application.initialize!
