class BusinessRule < ApplicationRecord
  has_many :business_rule_files, inverse_of: :business_rule
  has_many :additional_fields
  accepts_nested_attributes_for :business_rule_files, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :additional_fields, reject_if: :all_blank, allow_destroy: true


  ActiveSupport.run_load_hooks(:fat_free_crm_order, self)
end
