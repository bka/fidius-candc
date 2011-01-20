class CreateHostActiveConnection < ActiveRecord::Migration
  def self.up
    create_table :host_active_connections do |t|
      t.integer :host_id
      t.string :protocol
      t.string :local_address
      t.string :remote_address
      t.string :status
      t.string :pid
      t.timestamps
    end
  end

  def self.down
    drop_table :host_active_connections
  end
end
