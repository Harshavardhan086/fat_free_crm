class AddLeadIdToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :user_id, :integer
    add_column :orders, :status, :string
    add_column :orders, :state_of_incorporate, :string
    add_column :orders, :lead_id, :integer
    add_column :orders, :opportunity_id, :integer
    add_column :contacts, :order_id, :integer
  end
end
