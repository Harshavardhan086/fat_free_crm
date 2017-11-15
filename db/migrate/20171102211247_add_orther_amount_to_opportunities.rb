class AddOrtherAmountToOpportunities < ActiveRecord::Migration[5.0]
  def change
    add_column :opportunities, :other_amount, :decimal
    add_column :orders, :request_type, :string
  end
end
