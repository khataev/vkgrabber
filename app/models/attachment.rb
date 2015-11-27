class Attachment < ActiveRecord::Base
	has_many :rawfiles, :as => :fileable
end
