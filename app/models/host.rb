module Msf
  class DBManager
    class Host
      def exploited?
        exploited_hosts.size > 0
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
  end
end
