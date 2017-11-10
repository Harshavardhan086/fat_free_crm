class AddTotalToOpportunities < ActiveRecord::Migration[5.0]
  def change
    add_column :opportunities, :total_amount, :decimal
  end
end
