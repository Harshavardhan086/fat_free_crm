class BusinessRuleFile < ApplicationRecord
  belongs_to :business_rule ,inverse_of: :business_rule_files
  mount_uploader :attachment, BusinessRuleDocumentsUploader
end
