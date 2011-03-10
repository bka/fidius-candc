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
    return true if os_name.to_s.downcase == "prelude"
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
  
  # -------------   CVE-DB Stuff ------------- #
  
  # FIXME The search for NVD entries is quite ugly and should be done
  # a bit better. The performance is ok nevertheless. (About 5 seconds,
  # searching through 45.000 NVD entries)
  def nvd_entries
    entries = {}
    services.each do |service|
      # Only search for products where we have informations about the
      # version, otherwise there will be too many NVD entries (depending
      # on the nvd database).
      if service.info
        products = FIDIUS::CveDb::Product.find(:all,
                    :conditions => ["product IN (?) AND version IN (?)",
                                    service.products, service.versions])
        products.each do |product|
          product.nvd_entries.each do |entry|
            entries[entry.id] = entry unless entries.has_key? entry.id
          end
        end
      end
    end
    entries_array = []
    entries.each_key do |key|
      entries_array << entries[key]
    end
    entries_array
  end
  
  
end
