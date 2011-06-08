class EvasionDB::IdmefEvent < FIDIUS::XmlRpcModel

  column :id, :integer
  column :attack_module_id, :integer
  column :attack_payload_id, :integer
  column :payload, :binary
  column :detect_time, :datetime
  column :dest_ip, :string
  column :src_ip, :string
  column :dest_port
  column :src_port
  column :text, :string
  column :severity, :string
  column :analyzer_model, :string
  column :ident, :bigint
  column :created_at, :datetime
  column :updated_at, :datetime

  def self.query_name
    "FIDIUS::EvasionDB::Knowledge::IdmefEvent"
  end

  # overwritten to parse classnames like <attack-module>
  # in xml-reponse
  def self.xml_query_string
    "//idmef-event | //fidius-evasion-db-knowledge-idmef-event"
  end
end
