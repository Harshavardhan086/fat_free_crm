class AddAdditionalFieldsToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :additional_field, :text
  end
end
