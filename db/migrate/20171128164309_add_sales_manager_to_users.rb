class AddSalesManagerToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :sales_manager, :boolean
  end
end
