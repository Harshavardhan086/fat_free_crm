class AddAssignToToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :assigned_to, :integer
    add_column :orders, :access, :string, limit: 8, default: "Public"
  end
end
