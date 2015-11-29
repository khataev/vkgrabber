class Vgroup < ActiveRecord::Base
	has_many :rawfiles, :as => :fileable
	has_many :topics
	has_many :posts
end
