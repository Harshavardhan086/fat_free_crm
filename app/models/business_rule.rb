class BusinessRule < ApplicationRecord
  mount_uploaders :documents, BusinessRuleDocumentsUploader
end
