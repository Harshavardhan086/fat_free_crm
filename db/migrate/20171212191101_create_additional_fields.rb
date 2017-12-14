class CreateAdditionalFields < ActiveRecord::Migration[5.0]
  def change
    create_table :additional_fields do |t|
      t.string :business_rule_id
      t.string :name

      t.timestamps
    end
  end
end
