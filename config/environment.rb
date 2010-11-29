# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # initialization for MSF
  msf = YAML.load_file(File.join RAILS_ROOT, 'config', 'msf.yml')
  $:.unshift(File.join msf['msf_path'], 'lib')

	require 'rubygems' # XXX: ???
	require 'active_record'
	require 'msf/core/db_objects'
	require 'msf/core/model'

  # nochmal die models reinladen, nachdem wir die grundlegenden
  # sachen von msf geladen haben, um nachträglich noch modifizierungen
  # haben zu können
  Dir.glob(File.join 'app','models', '*.rb') do |rb|
    require rb
  end

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  config.frameworks -= [ :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

# This fix comes from https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/2283-unnecessary-exception-raised-in-asdependenciesload_missing_constant
# to avoid error "ArgumentError: Msf::DBManager is not missing constant Service!"

module ActiveSupport
  module Dependencies
    extend self
    def forgiving_load_missing_constant( from_mod, const_name )
      begin
        old_load_missing_constant(from_mod, const_name)
      rescue ArgumentError => arg_err
        if arg_err.message == "#{from_mod} is not missing constant #{const_name}!"
          return from_mod.const_get(const_name)
        else
          raise
        end
      end
    end
    alias :old_load_missing_constant :load_missing_constant
    alias :load_missing_constant :forgiving_load_missing_constant
  end
end

# load connection data for PreludeDB

require 'active_record/connection_adapters/postgresql_adapter'

PRELUDE_DB_CONFIG_NAME = 'prelude'
prelude_db_config_yaml = YAML.load_file(File.join RAILS_ROOT,"config/database.yml")
unless prelude_db_config = prelude_db_config_yaml[PRELUDE_DB_CONFIG_NAME]
  raise Exception.new 'There seems to be no prelude database config. Please see database.yml.example and reconfigure.'
end
PRELUDE_DB = prelude_db_config['database']

require 'config/initializers/postgres_patch.rb'

