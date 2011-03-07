class Task < FIDIUS::XmlRpcModel
  column :name, :string
  column :error, :string
  column :progress, :integer
  column :created_at, :datetime
  column :updated_at, :datetime
  column :completed, :boolean
end
