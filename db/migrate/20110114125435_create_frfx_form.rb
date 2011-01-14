class CreateFrfxForm < ActiveRecord::Migration
  def self.up
    create_table :frfx_forms do |t|
      t.integer :host_id
      t.string :form_name
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :frfx_forms
  end
end
