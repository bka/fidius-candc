class CreateHostTaskService < ActiveRecord::Migration
  def self.up
    create_table :host_task_services do |t|
      t.integer :host_id
      t.integer :pid
      t.string :service
      t.timestamps
    end
  end

  def self.down
    drop_table :host_task_services
  end
end
