class HostInterface < ActiveRecord::Migration
  def self.up
    create_table :host_interfaces do |t|
      t.integer :host_id
      t.string :name
      t.string :dns_suffix
      t.string :description
      t.string :mac
      t.boolean :DHCPActive
      t.boolean :AutoconfigActive
      t.string :address
      t.string :subnetmask
      t.string :defGateway
      t.string :DHCPServer
      t.string :DNSServer
      t.datetime :getLease
      t.datetime :leaseValidTil
      t.timestamps
    end
  end

  def self.down
    drop_table :host_interfaces
  end
end