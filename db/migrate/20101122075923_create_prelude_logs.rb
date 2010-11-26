class CreatePreludeLogs < ActiveRecord::Migration
  def self.up
    create_table :prelude_logs do |t|
      t.integer :task_id
      t.column :payload, :binary
      t.datetime :detect_time
      t.string :dest_ip
      t.string :src_ip
      t.string :text
      t.string :severity
      t.string :analyzer_model
      t.column :ident, :bigint
      t.timestamps
    end
  end

  def self.down
    drop_table :prelude_logs
  end
end
