require 'xmlrpc/client'

class FIDIUS::XmlRpcModel < ActiveRecord::Base
  def self.columns
    @columns ||= []
  end
 
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  def self.connect
    host = "127.0.0.1"
    port = "8080"
    ssl = false
    user = "msf"
    pass = "hallo"
    return XMLRPC::Client.new(host,"/",port)
  end

  # this finder is called via association_proxy to find associated model
  # use own relation to use self.find
  def self.construct_finder_arel(options = {}, scope = nil)
    FIDIUS::XMLRpcRelation.new(self,Arel::Table.new("DOES NOT MATTER"),options)
  end

  def self.find_by_sql(sql)
    raise "NOT AVAILABLE"
  end

  def self.first
    find(:first).first
  end

  def self.last
    find(:last).first
  end

  def self.find(*args)
    model_name = self.name
    call_rpc "model.find",model_name,args.to_json
  end
  
  def self.all(*args)
    find(:all, *args)
  end

  def self.call_rpc(method, *args)
    begin
      rpc = self.connect
      return parse_xml rpc.call(method,args)
    rescue XMLRPC::FaultException=>e
      raise "#{e.faultString}(#{e.faultCode})"
    end
    nil
  end

  # TODO: generalize this for all models ??
  def self.avaliable_models
    ["host","service"]
  end

  def self.xml_query_string
    # build string like '//host | //fidius-asset-host'
    res = Array.new
    avaliable_models.each do |model|
      res << "//#{model} | //fidius-asset-#{model} | //fidius-#{model}"
    end
    res.join("|")
  end

  def self.parse_xml(xml)
    #puts xml
    res = Array.new
    doc=REXML::Document.new(xml)
    doc.root.each_element(xml_query_string) do |tag|
      object = nil
      eval("object = #{model_name}.new")
      tag.each_element do |e|
        key = e.name
        key = key.gsub("-","_") # assoziations are returned like: host-id
        value = e.children.first
        if value
          eval("object.#{key} = '#{value}'")
        else
          eval("object.#{key} = nil")
        end
      end
      res << object
    end
    return res
  end

  def save(*args)
    raise "Not Implemented"
  end

  def update(*args)
    raise "Not Implemented"
  end

  def create(*args)
    raise "Not Implemented"
  end

  # overwrite to trick AssociationCollection.load_target 
  def new_record?
    false
  end
end
# Prevent ActiveRecord from loading via SQL-statements.
# Use our own Relation-Model
class FIDIUS::XMLRpcRelation < ActiveRecord::Relation
  def initialize(klass, table,options)
    super(klass,table)
    @find_options = options
  end
  def to_a
    @records = @klass.find(:all,*@find_options)
  end
end
