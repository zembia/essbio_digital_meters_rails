class CreateAlertTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :alert_types do |t|
      t.string :tag
      t.string :name

      t.timestamps
    end
  end
end
