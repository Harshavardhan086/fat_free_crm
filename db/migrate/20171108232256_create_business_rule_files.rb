class CreateBusinessRuleFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :business_rule_files do |t|
      t.string :business_rule_id
      t.string :file_name
      t.string :attachment
      t.timestamps
    end
  end
end
