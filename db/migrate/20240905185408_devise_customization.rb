class DeviseCustomization < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :tag
      t.timestamps
    end

    add_index :companies, :name, unique: true
    add_index :companies, :tag, unique: true

    add_column :users, :unique_email, :string
    add_reference :users , :company , foreign_key: true , index: true
  end
end
