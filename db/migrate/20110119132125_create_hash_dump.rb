class CreateHashDump < ActiveRecord::Migration
  def self.up
     create_table :hash_dumps do |t|
      t.integer :host_id
      t.string :hash_key
      t.timestamps
    end
  end

  def self.down
    drop_table :hash_dumps
  end
end
