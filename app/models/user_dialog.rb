class UserDialog < FIDIUS::XmlRpcModel
  DIALOG_TYPE_STANDARD=1
  DIALOG_TYPE_YES_NO = 2

  column :title, :string
  column :message, :string
  column :dialog_type, :integer
  column :created_at, :datetime
  column :updated_at, :datetime

  def self.fetch_next
    begin
      return UserDialog.find :first, :order=>"created_at"
    rescue
      puts $!.inspect
      # TODO
      # maybe we should check here if it is an object not found exception
    end
    nil
  end

end
