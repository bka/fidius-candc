class Session < FIDIUS::XmlRpcModel  
  column :id, :integer
  column :name, :string
  column :host_id, :integer
  column :service_id, :integer
  column :payload, :string
  column :exploit, :string
  column :created_at, :timestamp
  column :updated_at, :timestamp

  belongs_to :service
end
