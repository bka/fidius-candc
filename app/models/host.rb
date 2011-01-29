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
            products = CveDb::Product.find(:all,
                        :conditions => ["product IN (?) AND version IN (?)",
                                        service.products, service.versions])
            products.each do |product|
              product.nvd_entries.each do |entry|
                entries[entry.id.to_sym] = entry unless entries.has_key? entry.id.to_sym
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
  end
end
