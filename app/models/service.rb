class Service < FIDIUS::XmlRpcModel  
  column :id, :integer
  column :name, :string
  column :port, :integer
  column :proto, :string
  column :host_id, :integer
  column :exploited, :boolean
  column :state, :string
  column :info, :string

  belongs_to :host

  def exploited?
    exploited
  end
end
