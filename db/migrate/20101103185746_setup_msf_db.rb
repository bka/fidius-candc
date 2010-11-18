class SetupMsfDb < ActiveRecord::Migration
  def self.up
    msf = YAML::load(open(File.join(File.dirname(__FILE__), '..', '..', 'config', 'msf.yml')))
    ActiveRecord::Migrator.migrate(File.join(msf['msf_path'], 'data', 'sql', 'migrate'))
  end

  def self.down
  end
end
