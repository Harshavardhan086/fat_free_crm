class AddQbCustomerRefToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :qb_customer_ref, :int
  end
end
