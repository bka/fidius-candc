require "rexml/document"
require 'xmlrpc/client'
require 'fidius/rpc_commands'

class FIDIUS::XmlRpcModel < ActiveRecord::Base
  include FIDIUS::RpcCommands

  if Object.const_defined?("USE_RPC_FOR_MODELS") && USE_RPC_FOR_MODELS
    include FIDIUS::RpcModelActions
  end

  def self.columns
    @columns ||= []
  end
   
  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  def self.table_name
    "#{self.name.to_s.tableize}"
  end


  def self.connect
    # TODO: put this in a config-file
    host = "127.0.0.1"
    port = "8080"
    ssl = false
    user = "msf"
    pass = "hallo"
    return XMLRPC::Client.new(host,"/",port)
  end

  def self.xml_query_string
    # build string like '//host | //fidius-asset-host'
    res = Array.new
    available_models.each do |model|
      res << "//#{model.gsub("_","-")} | //#{model} | //fidius-asset-#{model} | //fidius-#{model} | // fidius-evasion-db-knowledge-#{model}"
    end
    res.join("|")
  end

  def self.parse_xml(xml)
    res = Array.new
    doc=REXML::Document.new(xml)
    doc.root.each_element(xml_query_string) do |tag|
      object = nil
      has_attr = false
      eval("object = #{model_name}.new")
      tag.each_element do |e|
        key = e.name
        key = key.gsub("-","_") # assoziations are returned like: host-id
        value = e.children.first
        # skip methods not found
        next if !object.respond_to?(key)
        if value
          eval("object.#{key} = '#{value}'")
        else
          eval("object.#{key} = nil")
        end
        has_attr = true
      end
      # avoid empty objects in array, strange bug ...
      res << object if has_attr
    end
    return res[0] if res.size == 1
    return res
  end

  private
    def self.rpc_request(*args)
      begin
        rpc = self.connect
        res = rpc.call(*args)
        rpc.close
        return res
      rescue
        begin
          original_error = $!
          m = $!.message
          message = m[0,m.index("[").to_i]
          t = m[m.index("[")+1,m.index("]")-1].gsub("\"","")
          trace = t.split(",")
          puts "Error: #{message}"
          puts "\t"+$!.backtrace.join("\n\t")
          puts ("#"*40)
          puts ("#"*10)+" Servers Stacktrace "+("#"*10)
          puts ("#"*40)
          puts "\t"+trace.join("\n\t")
        rescue
          puts "EE: "+original_error.message+"\n\n"+original_error.backtrace.join("\n")
        end
      end
      nil
    end

    def self.call_rpc(method, *args)
      rpc_request(method,args)
    end

end


# Prevent ActiveRecord from loading via SQL-statements.
# Use our own Relation-Model
class FIDIUS::XMLRpcRelation < ActiveRecord::Relation
  def initialize(klass, table,options)
    super(klass,table)
    @cur_klass = klass
    @find_options = options
  end

  def add_options(options)
    @find_options = @find_options.merge(options)
  end

  def to_a
    # avoid mysql syntax error in core
    @find_options[:conditions] = @find_options[:conditions].gsub("\"","")
    # replace namespaces like evasion_db/attack_options
    @find_options[:conditions] = @find_options[:conditions].gsub(@cur_klass.to_s.tableize,@cur_klass.to_s.tableize.split("/").last)    
    @records = @klass.find(:all,@find_options)
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
