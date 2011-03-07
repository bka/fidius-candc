class Host < FIDIUS::XmlRpcModel

  column :id, :integer
  column :pivot_host_id, :integer
  column :name, :string
  column :ip, :string
  column :exploited, :boolean
  column :os_name, :string
  column :os_sp, :string
  column :rating, :integer
  column :reachable_through_host_id, :integer

  has_many :services

  def address
    ip
  end

  def exploited?
    exploited
  end

  def exploited_hosts
    []
  end

  def image
    image = "windowsxp_hacked.png"
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
