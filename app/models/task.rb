module Msf
  class DBManager
    class Task
      has_many :payload_logs
      has_many :prelude_logs
      def self.find_new_tasks
        uncached do
          Msf::DBManager::Task.find(:all,:conditions=>{:progress=>nil,:error=>nil,:result=>nil})
        end
      end
    end
  end
end
