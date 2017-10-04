class OrderFile < ActiveRecord::Base
  belongs_to :order
  mount_uploader :attachment, OrderAttachmentUploader


  # uses_user_permissions
  # acts_as_commentable
  # uses_comment_extensions
  # has_fields
  # exportable

  # uses_user_permissions
  # acts_as_commentable
  # uses_comment_extensions
  # acts_as_taggable_on :tags
  # has_paper_trail class_name: 'Version', ignore: [:subscribed_users]
  # # has_fields
  # exportable

  # ActiveSupport.run_load_hooks(:fat_free_crm_order, self)
end
