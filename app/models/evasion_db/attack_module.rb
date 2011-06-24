class EvasionDB::AttackModule < FIDIUS::XmlRpcModel
  unless (Object.const_defined?("USE_RPC_FOR_MODELS") && USE_RPC_FOR_MODELS)
    establish_connection 'evasion_db'
    set_table_name "attack_modules"
  end

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

  def self.get_exploits_for_host(host_id)
    exploit_ids = exec_get_exploits_for_host(host_id)
    exploits = []
    exploit_ids.each do |id|
      exploits << find(id)
    end
    exploits
  end

end
