class AddEventCacheIdToPayloadLogs < ActiveRecord::Migration
  def self.up
    add_column :payload_logs, :prelude_log_id, :integer
  end

  def self.down
    remove_column :payload_logs,:prelude_log_id
  end
end
