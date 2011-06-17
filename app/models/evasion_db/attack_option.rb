class EvasionDB::AttackOption < FIDIUS::XmlRpcModel
  establish_connection 'evasion_db'
  set_table_name "attack_options"

  column :id, :integer
  column :created_at, :datetime
  column :updated_at, :datetime

  column :attack_module_id, :integer
  column :option_key, :string
  column :option_value, :string

  belongs_to :attack_module, :class_name=>"EvasionDB::AttackModule"


  def self.query_name
    "FIDIUS::EvasionDB::Knowledge::AttackOption"
  end

  # overwritten to parse classnames like <attack-option>
  # in xml-reponse
  def self.xml_query_string
    "//attack-option | //fidius-evasion-db-knowledge-attack-option"
  end

end
