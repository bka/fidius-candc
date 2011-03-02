class Event < FIDIUS::XmlRpcModel

  column :id, :integer
  column :title, :string
  column :message, :string
  column :response, :integer
  column :created_at, :datetime
  column :updated_at, :datetime
  def self.fetch_next
    begin
      return Event.find :first, :order=>"created_at"
    rescue
      puts $!.inspect
      # TODO
      # maybe we should check here if it is an object not found exception
    end
    nil
  end

end
