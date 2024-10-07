class CreateFeeTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :applied_fee_types do |t|
      t.string :label
      t.boolean :base
      t.boolean :ap
      t.boolean :al
      t.boolean :tas

      t.timestamps
    end

  end
end
