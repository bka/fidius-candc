class PreludeLog < ActiveRecord::Base
  def payload
    return [] if self[:payload] == nil
    self[:payload]
  end
end
