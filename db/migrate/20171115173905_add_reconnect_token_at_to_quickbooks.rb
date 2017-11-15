class AddReconnectTokenAtToQuickbooks < ActiveRecord::Migration[5.0]
  def change
    add_column :quickbooks, :reconnect_token_at, :datetime
  end
end
