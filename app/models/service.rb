class Service < FIDIUS::XmlRpcModel  
  column :id, :integer
  column :name, :string
  column :port, :integer
  column :proto, :string
  column :host_id, :integer
  belongs_to :host
end
