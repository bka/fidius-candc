class Msf::DBManager::Task
  has_many :payload_logs
  has_many :prelude_logs
  
  def self.find_new_tasks
    uncached do
      all(
        :conditions => {
          :progress => nil,
          :error => nil,
          :result => nil
        }
      )
    end
  end
end

