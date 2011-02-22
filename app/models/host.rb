require 'fidius/xml_rpc_model'
class Host < FIDIUS::XmlRpcModel

  column :id, :integer
  column :name, :string
  column :ip, :string

  has_many :services

  def address
    "address"
  end

  def exploited?
    true
  end

  def exploited_hosts
    []
  end

  def os_name
    "windows"
  end

  def pivot_host_id
    nil
  end

  def image
    image = "unknownpc.png"
    image = "unknownpc_hacked.png" if exploited?

    if is_windows?
      image = "windowsxp.png"
      image = "windowsxp_hacked.png" if exploited?
    end
    return image
  end
  
  def is_windows?
    return true if os_name.to_s.downcase["windows"] != nil
    return true if name.to_s.downcase["windows"] != nil
    return true if os_sp.to_s.downcase["windows"] != nil
    services.each do |s|
      return true if s.info.to_s.downcase["windows"] != nil
      return true if s.name.to_s.downcase["windows"] != nil
    end
    return false
  end
end
