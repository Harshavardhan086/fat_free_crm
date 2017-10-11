class AddQbInvoiceRefIdToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :qb_invoice_ref, :integer
  end
end
