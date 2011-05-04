class Host < FIDIUS::XmlRpcModel
  def self.fixtures
    [self.new(:id=>1,:ip=>"192.168.178.1",:os_name=>"windows",:os_sp=>"SP2"),
     self.new(:id=>2,:ip=>"177.12.11.2",:os_name=>"windows",:os_sp=>"SP2"),
     self.new(:id=>3,:ip=>"192.33.66.77",:os_name=>"windows",:os_sp=>"SP2")]
  end
end
class Service < FIDIUS::XmlRpcModel
  def self.fixtures
    [self.new(:id=>1,:name=>"http",:port=>80,:proto=>"http",:host_id=>1,:state=>"open",:exploited=>true),
     self.new(:id=>2,:name=>"ssh",:port=>22,:proto=>"ssh",:host_id=>2,:state=>"open",:exploited=>true),
     self.new(:id=>2,:name=>"ftp",:port=>21,:proto=>"ftp",:host_id=>2,:state=>"open",:exploited=>true)]
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
    if opts.first == :all
      return model.fixtures
    end
    if opts.first == :first
      return model.fixtures.first
    end
    if opts.first == :last
      return model.fixtures.last
    end
    return nil
  end
end
