class Host < FIDIUS::XmlRpcModel
  def self.columns
    @columns ||= []
  end
 
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  column :name, :string
  column :ip, :string
  column :service_id, :integer
  
  belongs_to :service
end
