class AddAccountToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :account_id, :integer
  end
end
