class PayloadLog < ActiveRecord::Base
  belongs_to :task, :class_name=>"Msf::DBManager::Task"
  belongs_to :prelude_log

  def payload
    return [] if self[:payload] == nil
    self[:payload]
  end

end
