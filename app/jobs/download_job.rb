class DownloadJob < ProgressJob::Base
  def initialize(group_id, token)
    @group_id = group_id
    @token = token

    #puts "DownloadJob initialize, group_id=#{@group_id}"
    #puts "DownloadJob initialize, token=#{@token}"
  end

  def perform

    #puts "DownloadJob perform, group_id: #{@group_id}"
    #puts "DownloadJob perform, token: #{@token}"
    update_progress_max(100)
    unless @group_id.nil? || @group_id == 0  
      #vkgg.purgeDatabase
      vkgg.logGroup(@group_id) 
    else
      raise "Group ID is nil"
    end
  end

  def max_attempts
    1
  end

  def vkgg
    VkHelper::VkGroupGrabber.new(@token, self)
  end
end