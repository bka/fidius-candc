require 'fidius/xml_rpc_model'
class Host < FIDIUS::XmlRpcModel

  column :id, :integer
  column :name, :string
  column :ip, :string

  has_many :services
end
