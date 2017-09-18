class AddOrderToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :order_id, :integer
  end
end
