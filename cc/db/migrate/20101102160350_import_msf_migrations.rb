class ImportMsfMigrations < ActiveRecord::Migration
  def self.up
    yaml = YAML::load(open(File.join(File.dirname(__FILE__), '..', '..', 'config', 'msf.yml')))
    Dir.chdir(File.join(yaml['msf_lib'], 'lib', 'msf', 'core')) do |path|
      $LOAD_PATH.unshift path
      require File.join('.', 'db.rb')
      ActiveRecord::Migrator.migrate(File.join(yaml['msf_lib'], 'data', 'sql', 'migrate'))
    end
  end

  def self.down
  end
end
