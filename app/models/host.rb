class Host < FIDIUS::XmlRpcModel

  column :id, :integer
  column :name, :string
  column :rating, :integer
  column :os_name, :string
  column :os_sp, :string
  column :pivot_host_id, :integer
  column :arch, :string
  column :localhost, :boolean
  column :attackable, :boolean
  column :ids, :boolean
  column :webserver, :string
  column :discovered, :boolean
  column :os_info, :string
  column :lang, :string

  has_many :interfaces
  has_many :sessions

  attr_accessor :marked

  #needed for tests with rpc-models
  if ENV['RAILS_ENV'] == "test"
    attr_accessible :id, :os_name, :os_sp, :name, :rating, :pivot_host_id, :arch, :localhost, :attackable, :ids, :webserver, :discovered, :os_info, :lang
  end
  #XXX: remove this method and fix the real bug
  def interfaces2
    interfaces.select {|i| i.host_id == id }
  end

  #XXX: remove this method and fix the real bug
  def sessions2
    sessions.select {|s| s.host_id == id }
  end

  def exploited?
    !sessions2.empty?
  end

  def exploited_hosts
    []
  end

  def image
    image = "unknownpc.png"
    image = "unknownpc_hacked.png" if exploited?

    if is_windows?
      image = "windowsxp.png"
      image = "windowsxp_hacked.png" if exploited?
    end
    if is_linux?
      image = "linux.png"
      image = "linux_hacked.png" if exploited?

    end

    if is_prelude?
      image = "prelude.png"
    end
    return image
  end
  
  def is_prelude?
    ids
  end

  def name_for_graphview
    return name if name
    return interfaces2.first.ip if interfaces2.size>0
    return "UNKNOWN"
  end

  def is_linux?
    return true if os_name.to_s.downcase["ubuntu"] != nil
  end

  def is_windows?
    return true if os_name.to_s.downcase["windows"] != nil
    return true if name.to_s.downcase["windows"] != nil
    return true if os_sp.to_s.downcase["windows"] != nil
    self.interfaces.each do |i|
      i.services.each do |s|
        return true if s.info.to_s.downcase["windows"] != nil
        return true if s.name.to_s.downcase["windows"] != nil
      end
    end
    return false
  end

  def marked?
    return @marked == true
  end

  def processes
    [{:pid=>4,:name=>"System",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>""},
{:pid=>348,:name=>"smss.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>" SystemRoot System32 Smss.exe"},
{:pid=>536,:name=>"csrss.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>"??C:\\WINDOWS System32\\csrss.exe"},
{:pid=>560,:name=>"winlogon.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>"\\??\\C:\\WINDOWS System32\\winlogon.exe"},
{:pid=>856,:name=>"services.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>"C:\WINDOWS System32 Services.exe"},
{:pid=>868,:name=>"lsass.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>"C:\\WINDOWS System32\\lsass.exe"},
{:pid=>1032,:name=>"svchost.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>"C:\\WINDOWS System32 Svchost.exe"},
{:pid=>1100,:name=>"svchost.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT NETZWERKDIENST",:path=>"C:\\WINDOWS System32 Svchost.exe"},
{:pid=>1312,:name=>"svchost.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>"C:\WINDOWS System32 Svchost.exe"},
{:pid=>1364,:name=>"svchost.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT NETZWERKDIENST",:path=>"C:\\WINDOWS System32 Svchost.exe"},
{:pid=>1428,:name=>"svchost.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT LOKALER DIENST",:path=>"C:\\WINDOWS System32 Svchost.exe"},
{:pid=>1792,:name=>"spoolsv.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>"C:\\WINDOWS System32 Spoolsv.exe"},
{:pid=>1936,:name=>"FreeFTPDService.exe",arch=>"x86",:user=>"NT-AUTORITAT SYSTEM",:path=>"C:\\Programme\\freeFTPd\\FreeFTPdService.exe"},
{:pid=>1148,:name=>"alg.exe",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT LOKALER DIENST",:path=>"C:\\WINDOWS System32\\alg.exe"},
{:pid=>1652,:name=>"logon.scr",:arch=>"x86",:session=>0,:user=>"NT-AUTORITAT SYSTEM",:path=>"C:\\WINDOWS System32\\logon.scr"},
]
  end

  def has_ip? ip
    interfaces2.select {|i| i.ip == ip}.length >= 1
  end

end
