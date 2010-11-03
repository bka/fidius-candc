module Msf
  class DBManager
    class Host
      def exploited?
        exploited_hosts.size > 0
      end
    end
  end
end
