class AddPivotHostIdToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :pivot_host_id, :integer
  end

  def self.down
    remove_column :hosts, :pivot_host_id
  end
end
