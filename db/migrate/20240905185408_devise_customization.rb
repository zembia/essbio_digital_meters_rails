class DeviseCustomization < ActiveRecord::Migration[7.2]
  def change
    create_table :apps do |t|
      t.string :name
      t.string :tag
      t.timestamps
    end

    add_index :apps, :name, unique: true
    add_index :apps, :tag, unique: true

    remove_index :users, :email
    add_index :users, :email, name: "index_users_on_email"
    add_reference :users, :app , foreign_key: true , index: true
  end
end
