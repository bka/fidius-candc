class CreateHostTasklist < ActiveRecord::Migration
  def self.up
    create_table :host_tasklists do |t|
      t.integer :host_id
      t.string :name
      t.integer :pid
      t.timestamps
    end
  end

  def self.down
    drop_table :host_tasklists
  end
end
