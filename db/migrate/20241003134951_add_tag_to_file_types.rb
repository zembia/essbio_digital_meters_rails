class AddTagToFileTypes < ActiveRecord::Migration[7.2]
  def change
    add_column :file_types, :tag, :string
  end
end
