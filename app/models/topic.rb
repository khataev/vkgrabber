class Topic < ActiveRecord::Base
	has_many :comments, :as => :commentable
	belongs_to :vgroup
end
