class CreateBusinessRules < ActiveRecord::Migration[5.0]
  def change
    create_table :business_rules do |t|
      t.string :state_of_incorporate
      t.string :request_type
      t.string :amount
      t.json :documents
      t.string :web
      t.timestamps
    end
  end
end
