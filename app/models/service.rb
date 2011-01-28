class Msf::DBManager::Service
  def exploited?
    exploited_hosts.size > 0
  end
end
