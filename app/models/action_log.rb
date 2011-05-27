class ActionLog < FIDIUS::XmlRpcModel
  column :id, :integer
  column :title, :string
  column :source_host_id, :integer
  column :dest_host_id, :integer
  column :time, :datetime

  belongs_to :host

  def idmef_count
    5
  end

  def time
    Time.now
  end
end
