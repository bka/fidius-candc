require 'xmlrpc/client'
class FIDIUS::XmlRpcModel < ActiveRecord::Base
  def self.connect
    host = "127.0.0.1"
    port = "55553"
    ssl = false
    user = "msf"
    pass = "hallo"

    return Client.new(
      :host => host,
      :port => port,
      :ssl  => ssl
    )  
  end

  def self.find(*args)
    rpc = self.connect
    rpc.call("model.#{self.name}.find", *args)
  end
  
  def self.all(*args)
    find(:all, *args)
  end
end
