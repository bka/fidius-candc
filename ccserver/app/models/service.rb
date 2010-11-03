module Msf
  class DBManager
    class Service
      def exploited?
        exploited_hosts.size > 0
      end
    end
  end
end
