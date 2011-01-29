class Msf::DBManager::Service      
  
  # Contains words which may be included in the service.info but are
  # irrelevant for searching products. (Products are used to find
  # corresponding NVD entries.)
  SERVICE_INFO_JUNK_WORDS = %w{with or db protocol workgroup}

  def exploited?
    exploited_hosts.size > 0
  end

  def versions
    # Should match any word which contains a "number dot number" followed
    # by other letters or numbers, e.g: "1.8.5", "4.7p1"
    info.scan(/\b\d+\.\d+\S*\b/)
  end

  def products
    info.split - versions - SERVICE_INFO_JUNK_WORDS
  end
end
