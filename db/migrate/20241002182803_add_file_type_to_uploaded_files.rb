class AddFileTypeToUploadedFiles < ActiveRecord::Migration[7.2]
  def change
    add_reference :uploaded_files, :file_type, null: false, foreign_key: true
  end
end