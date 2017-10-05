class CreateQuickbooks < ActiveRecord::Migration[5.0]
  def change
    create_table :quickbooks do |t|
      t.string :realmId
      t.string :refresh_token
      t.string :access_token, :limit => 1000

      t.timestamps
    end
  end
end
