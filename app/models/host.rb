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
  has_many :services, :through => :interfaces

  attr_accessor :marked

  #needed for tests with rpc-models
  if ENV['RAILS_ENV'] == "test"
    attr_accessible :id, :os_name, :os_sp, :name, :rating, :pivot_host_id, :arch, :localhost, :attackable, :ids, :webserver, :discovered, :os_info, :lang
  end

  def exploited?
    !sessions.empty?
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
      image = "linux_new.png"
      image = "linux_new_hacked.png" if exploited?

    end
    if is_apple?
      image = "apple.png"
      image = "apple_hacked.png" if exploited?
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
    return interfaces.first.ip if interfaces.size>0
    return "UNKNOWN"
  end

  def is_linux?
    return true if os_name.to_s.downcase["ubuntu"] != nil
    return true if os_name.to_s.downcase["linux"] != nil
    return true if os_name.to_s.downcase["debian"] != nil
    return true if os_name.to_s.downcase["suse"] != nil
  end
  
  def is_apple?
    return true if os_name.to_s.downcase["apple"] != nil
    return true if os_name.to_s.downcase["mac"] != nil
    return true if os_name.to_s.downcase["darwin"] != nil
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
    return unless sessions.first
    FIDIUS::XmlRpcModel.get_processes sessions.first.id
  end

  def has_ip? ip
    interfaces.select {|i| i.ip == ip}.length >= 1
  end
  
  # ---------------  CVE-DB Stuff --------------- #
  
  def nvd_entries
    entries = {}
    services.each do |service|
      if service.info
        # If we don't have version informations we only search for the product
        # names. (which unfortunately will result in many cve entries)
        if service.versions.empty?
          conditions  = ["product IN (?)", service.products]
        else
          conditions  = ["product IN (?) AND version IN (?)", service.products,
                         service.versions]
        end
        products = FIDIUS::CveDb::Product.find(:all, :conditions => conditions)
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
