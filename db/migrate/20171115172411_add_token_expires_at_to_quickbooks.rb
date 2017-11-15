class AddTokenExpiresAtToQuickbooks < ActiveRecord::Migration[5.0]
  def change
    add_column :quickbooks, :token_expires_at, :datetime
  end
end
