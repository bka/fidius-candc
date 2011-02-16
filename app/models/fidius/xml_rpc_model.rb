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

  def self.find(*args)
    rpc = self.connect
    puts self.name
    xml = rpc.call("model.host.find",1)
    doc=REXML::Document.new(xml)

    self.name
    doc.root.each_element('//host') do |tag|
      object = Host.new
      tag.each_element do |e|
        key = e.name
        value = e.children.first
        eval("object.#{key} = #{value}")
      end
      puts object.inspect
    end
    nil
  end
  
  def self.all(*args)
    find(:all, *args)
  end
end
