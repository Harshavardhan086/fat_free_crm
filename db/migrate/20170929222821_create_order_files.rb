class CreateOrderFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :order_files do |t|
      t.integer :order_id
      t.string :file_name
      t.string :attachment

      t.timestamps
    end
  end
end
