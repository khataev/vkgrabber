class MainController < ApplicationController
	# Delay between requests to VK API. Too frequent requests prohibited for small apps
	# REQUEST_DELAY = 0.2

	#@is_view
	#@groups
	#@user
	#@vkgg

	def index
		#byebug
		#@is_view = true
		#@user = vkgg.get_user_json(session[:vk_id])

		#load_group
		#view_internal
		redirect_to action: :view, format: :js
	end

  def view
		view_internal
  end

  def download
  	@is_view = false
  	@user = vkgg.get_user_json(session[:vk_id])	
  	@groups = vkgg.get_current_user_groups_json
  	#render 'main/index'
  end

  private

  def vkgg
  	@vk ||= VkHelper::VkGroupGrabber.new(session[:token])
	end

	def view_internal
    Delayed::Job.enqueue GetUserJob.new(session[:token], session[:vk_id])
    #@user = vkgg.get_user_json(session[:vk_id])

		#load_group
	end

  def view_internal_prev
    @user = vkgg.get_user_json(session[:vk_id])
    load_group
  end

	def load_group
		group = Vgroup.last
		@wall_posts = group.posts.order(:created_at)
		@empty_wall = @wall_posts.count == 0

		@discussions = group.topics.order(:created_at)
		@empty_topics = @discussions.count == 0
	end


end
