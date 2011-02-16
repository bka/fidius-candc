class Service < FIDIUS::XmlRpcModel
  def self.columns
    @columns ||= []
  end
 
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end
  
  column :name, :string
  column :port, :integer
  column :proto, :string
  
  has_many :hosts
end
