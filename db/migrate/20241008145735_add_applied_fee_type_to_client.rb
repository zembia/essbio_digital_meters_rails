class AddAppliedFeeTypeToClient < ActiveRecord::Migration[7.2]
  def change
    add_reference :clients, :applied_fee_type, index: true, foreign_key: true
  end
end
