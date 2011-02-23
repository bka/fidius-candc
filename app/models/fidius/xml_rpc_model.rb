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
    find(:first)
  end

  def self.last
    find(:last)
  end

  def self.find(*args)
    model_name = self.name
    call_rpc "model.find",model_name,args.to_json
  end
  
  def self.all(*args)
    res = find(:all, *args)
    return [res] if !res.respond_to?("size")
    res
  end

  def self.call_rpc(method, *args)
    begin
      rpc = self.connect
      result = parse_xml rpc.call(method,args)
      # important close this connection
      # server can only handle a limited amount of open connections
      rpc.close
      return result
    rescue XMLRPC::FaultException=>e
      raise "#{e.faultString}(#{e.faultCode})"
    end
    objects
  end

  def self.available_models
    # find all models in app/models 
    path = "#{RAILS_ROOT}/app/models/"
    Dir.foreach(path).select do |file|
      !File.directory?(path+file)
    end.map do |filename|
      filename.gsub(".rb","")
    end
  end

  def self.xml_query_string
    # build string like '//host | //fidius-asset-host'
    res = Array.new
    available_models.each do |model|
      res << "//#{model} | //fidius-asset-#{model} | //fidius-#{model}"
    end
    res.join("|")
  end

  def self.parse_xml(xml)
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
    return res[0] if res.size == 1
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
    return [@records] if !@records.respond_to?("size")
    @records
  end
end

module XMLRPC
  class Client
    # need access to http object for closing the http-socket
    # cleanup our crap and leave no open connections
    def close
      @http.finish
    end
  end
end
