class GroupsController < ApplicationController

	def index
	end

	def download_process
    @job = Delayed::Job.enqueue DownloadJob.new(session[:group_id].to_i, session[:token]), :queue => 'vkgrabber'
    #@job = Delayed::Job.enqueue DownloadJob.new(1, 2), :queue => 'vkgrabber'
  end

  def download
  	group_id = params[:id].to_i
  	session[:group_id] = params[:id]

  	#byebug
  	groups = vkgg.get_current_user_groups_json
  	@group = groups.select{ |group| group.id == group_id }.first
  	#download_process(group_id)
  	#byebug
  	#vkgg.purgeDatabase
  	#vkgg.logGroup(group_id) unless group_id.nil?
  end

  private 
    def vkgg
  		VkHelper::VkGroupGrabber.new(session[:token])
  	end
end
