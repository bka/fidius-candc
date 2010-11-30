class AddPortsToPreludeLogs < ActiveRecord::Migration
  def self.up
    add_column :prelude_logs, :src_port, :integer
    add_column :prelude_logs, :dest_port, :integer
  end

  def self.down
    remove_column :prelude_logs, :src_port
    remove_column :prelude_logs, :dest_port
  end
end
