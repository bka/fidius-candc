class CreateWorkerLogs < ActiveRecord::Migration
  def self.up
    create_table :worker_logs do |t|
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
