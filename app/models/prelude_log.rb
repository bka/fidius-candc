class PreludeLog < ActiveRecord::Base
  has_many :payload_logs

  def payload
    return [] if self[:payload] == nil
    self[:payload]
  end

  def get_payloads_logs
    payload_logs
  end
end
