class Host < FIDIUS::XmlRpcModel
  def self.fixtures
    [self.new(:id=>1,:os_name=>"windows",:os_sp=>"SP2"),
     self.new(:id=>2,:os_name=>"windows",:os_sp=>"SP2"),
     self.new(:id=>3),
     self.new(:id=>4,:os_name=>"windows",:os_sp=>"SP2"),
     self.new(:id=>5,:os_name=>"windows",:os_sp=>"SP2")]
  end
end
class Service < FIDIUS::XmlRpcModel
  def self.fixtures
    [self.new(:id=>1,:name=>"http",:port=>80,:proto=>"http",:interface_id=>3,:state=>"open"),
     self.new(:id=>2,:name=>"ssh",:port=>22,:proto=>"ssh",:interface_id=>2,:state=>"open"),
     self.new(:id=>3,:name=>"ftp",:port=>21,:proto=>"ftp",:interface_id=>2,:state=>"open")]
  end
end

class Interface < FIDIUS::XmlRpcModel
  def self.fixtures
    [self.new(:id=>1,:ip=>"192.168.178.1", :host_id=>1),
     self.new(:id=>2,:ip=>"177.12.11.2", :host_id=>2),
     self.new(:id=>3,:ip=>"192.33.66.77", :host_id=>3),
     self.new(:id=>4,:ip=>"192.33.66.78", :host_id=>4)]
  end
end

class Session < FIDIUS::XmlRpcModel
  def self.fixtures
    [self.new(:id=>2, :host_id=>2, :service_id=>2),
     self.new(:id=>3, :host_id=>3, :service_id=>3),
     self.new(:id=>4, :host_id=>4, :service_id=>3)]
  end
end

module FIDIUS::RpcModelActions
  class FIDIUS::XmlRpcModel < ActiveRecord::Base
    def self.find(*args)
      if self.respond_to?("query_name")
        model_name = self.query_name
      else
        model_name = self.name
      end
      call_rpc "model.find",model_name,args.to_json
    end
  end
end

class FIDIUS::XmlRpcModel < ActiveRecord::Base
  # test stub for testing models without dependecy to xmlrpc-server

  def self.call_rpc(method, *args)
    model_name = args.shift
    model = nil
    begin
      # search model in FIDIUS namespace
      model = Kernel.const_get(model_name)
    rescue 
    end    
    raise "model #{model_name} not found " unless model
    opts = ActiveSupport::JSON.decode(args[0])
    p opts
    if opts.first == :all
      if opts[1]
        s = opts[1][:conditions]
        return model.fixtures.select {|i| eval(s.gsub(/^#{model.to_s.tableize}\./, "i." ).gsub(/=/, "==").gsub(/\bNULL\b/,"nil"))}
      else
        return model.fixtures
      end
    end
    if opts.first == :first
      return model.fixtures.first
    end
    if opts.first == :last
      return model.fixtures.last
    end
    if opts.first.integer?
      return model.fixtures.each {|m| return m  if m.id == opts.first}
    end
    return nil
  end
end
