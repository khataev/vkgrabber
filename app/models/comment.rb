class Comment < ActiveRecord::Base
	belongs_to :commentable, :polymorphic => true
	has_many :attachments, :as => :attachmentable
end

