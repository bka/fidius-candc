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

  #needed for tests with rpc-models
  if ENV['RAILS_ENV'] == "test"
    attr_accessible :id, :name, :host_id, :service_id, :payload, :exploit
  end

end
