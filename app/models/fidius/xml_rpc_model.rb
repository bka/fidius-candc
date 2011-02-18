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

  def to_a
    puts "to_a"
  end

  def self.first
    find(:first)
  end

  def self.last
    find(:last)
  end

  def self.find(*args)
    puts "find #{args.inspect}"
    # TODO: find :all
    # TODO: more generic, not only hosts
    model_name = self.name
    call_rpc "model.#{model_name.downcase}.find",*args
  end
  
  def self.all(*args)
    find(:all, *args)
  end

  def self.call_rpc(method, *args)
    begin
      rpc = self.connect
      puts "parse_xml #{method} #{args.inspect}"
      return parse_xml rpc.call(method,args)
    rescue XMLRPC::FaultException=>e
      raise "#{e.faultString}(#{e.faultCode})"
      #puts "ERROR: *"
      #puts "CODE: #{e.faultCode}"
      #puts "FAULT: #{e.faultString}"
    end
    nil
  end

  def self.parse_xml(xml)

    res = Array.new
    doc=REXML::Document.new(xml)
    doc.root.each_element('//host | //fidius-asset-host') do |tag|
      object = nil
      eval("object = #{model_name}.new")
      tag.each_element do |e|
        key = e.name
        value = e.children.first
        if value
          eval("object.#{key} = #{value}")
        else
          eval("object.#{key} = nil")
        end
      end
      res << object
      puts object.inspect
    end
    return res
  end
end
