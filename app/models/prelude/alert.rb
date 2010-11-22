class Prelude::Alert < Prelude::Connection
  has_one :detect_time, :class_name => 'Prelude::DetectTime', :foreign_key => :_message_ident, :primary_key => :_ident

  has_one :source_address, :class_name => 'Prelude::Address', :foreign_key => :_message_ident, :primary_key => :_ident, :conditions => [ "Prelude_Address._parent_type = 'S'" ]
  has_one :dest_address, :class_name => 'Prelude::Address', :foreign_key => :_message_ident, :primary_key => :_ident, :conditions => [ "Prelude_Address._parent_type = 'T'" ]

  has_one :classification, :class_name => 'Prelude::Classification', :foreign_key => :_message_ident, :primary_key => :_ident
  has_one :analyzer, :class_name => 'Prelude::Analyzer', :foreign_key => :_message_ident, :primary_key => :_ident

  has_one :impact, :class_name => 'Prelude::Impact', :foreign_key => :_message_ident, :primary_key => :_ident

  has_one :payload, :class_name => 'Prelude::AdditionalData', :foreign_key => :_message_ident, :primary_key => :_ident, :conditions=>["Prelude_AdditionalData.meaning='payload'"]

  set_primary_key :_ident

  def self.table_name
    "Prelude_Alert"
  end

  def self.total_entries
    sql = connection();
	  sql.begin_db_transaction
	  value = sql.execute("SELECT count(*) FROM Prelude_Alert;").fetch_row;
	  sql.commit_db_transaction
	  value[0].to_i;
  end

  #def self.find(*a)
  #  a = super.find(a)
  #  puts "FOUND ALERTS:"
  #  return a
  #end

  def source_ip
    source_address.address
  end

  def dest_ip
     dest_address.address
  end

  def severity
    return impact.severity
  end

  def payload_data
    payload.data if payload != nil
  end
end
