class Post < ActiveRecord::Base
	has_many :comments, :as => :commentable
	has_many :attachments, :as => :attachmentable
	belongs_to :vgroup
end
