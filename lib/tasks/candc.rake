namespace :check do
  desc 'Measures test coverage'
  task :config do
    require "#{RAILS_ROOT}/app/helpers/config_helper.rb"
    include ConfigHelper
    begin
      check_config
      puts "Config is valid"
    rescue Exception
      puts "#{$!.message}"
    end
  end
end
