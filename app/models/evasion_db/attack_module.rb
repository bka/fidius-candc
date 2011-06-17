class EvasionDB::AttackModule < FIDIUS::XmlRpcModel
  establish_connection 'evasion_db'
  set_table_name "attack_modules"

  column :id, :integer
  column :created_at, :datetime
  column :updated_at, :datetime
  column :name, :string

  has_many :attack_options, :class_name=>"EvasionDB::AttackOption"
  has_many :idmef_events, :class_name=>"EvasionDB::IdmefEvent"

  def self.query_name
    "FIDIUS::EvasionDB::Knowledge::AttackModule"
  end

  # overwritten to parse classnames like <attack-module>
  # in xml-reponse
  def self.xml_query_string
    "//attack-module | //fidius-evasion-db-knowledge-attack-module"
  end
end
