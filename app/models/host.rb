class Host < FIDIUS::XmlRpcModel

  column :id, :integer
  column :name, :string
  column :rating, :integer
  column :exploited, :boolean
  column :os_name, :string
  column :os_sp, :string
  column :pivot_host_id, :integer
  column :arch, :string
  column :localhost, :boolean
  column :attackable, :boolean
  column :ids, :boolean

  has_many :interfaces
  has_many :sessions

  #XXX: remove this method and fix the real bug
  def interfaces2
    interfaces.select {|i| i.host_id == id }
  end

  #XXX: remove this method and fix the real bug
  def sessions2
    sessions.select {|s| s.host_id == id }
  end

  def exploited?
    exploited
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
    if is_prelude?
      image = "prelude.png"
    end
    return image
  end
  
  def is_prelude?
    ids
  end

  def is_windows?
    return os_name.to_s.downcase == "windows"
  end

end
