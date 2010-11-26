class CreatePayloadLogs < ActiveRecord::Migration
  def self.up
    create_table :payload_logs do |t|
      t.string :src_addr
      t.string :dest_addr
      t.string :src_port
      t.string :dest_port
      t.integer :task_id
      t.column :payload, :binary
      t.string :exploit
      t.timestamps
    end
  end

  def self.down
    drop_table :payload_logs
  end
end
