class Service < FIDIUS::XmlRpcModel  
  column :id, :integer
  column :name, :string
  column :port, :integer
  column :proto, :string
  column :interface_id, :integer
  column :state, :string
  column :info, :string

  belongs_to :interface

  def exploited?
    interface.host.sessions2.each do |session|
      return true if session.service_id == id
    end
  end

  # ---------------  CVE-DB Stuff --------------- #
  
  # Contains words which may be included in the service.info but are
  # irrelevant for searching products. (Products are used to find
  # corresponding NVD entries.)
  SERVICE_INFO_JUNK_WORDS = %w{with or db protocol workgroup}

  def versions
    # Should match any word which contains a "number dot number" followed
    # by other letters or numbers, e.g: "1.8.5", "4.7p1"
    info.scan(/\b\d+\.\d+\S*\b/)
  end

  def products
    info.split - versions - SERVICE_INFO_JUNK_WORDS
  end
end
