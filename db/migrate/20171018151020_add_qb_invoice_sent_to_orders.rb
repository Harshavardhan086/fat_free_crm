class AddQbInvoiceSentToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :qb_invoice_sent, :tinyint, default: 0
  end
end
