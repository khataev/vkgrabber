require 'faraday'
require 'json'

module VkHelper

	# Class for group grabbing
	class VkGroupGrabber
		REQUEST_DELAY = 0.2 

		#@token
		#@group_id

		# token - token from user authorization
		
		def initialize(token, job = nil)
			@token = token
			@job = job
			@stage_description = JobStageDescription.new
		end

		def get_user_json(uid)
			user = vk.users.get(uid: uid, fields: [:screen_name, :photo]).first
			user
		end

		def get_current_user_groups_json
			raw_groups = vk.groups.get(extended: 1)
			raw_groups[:items]
		end

		def purgeDatabase
			@job.update_progress_max(1) unless @job.nil?
			@stage_description.stage_name = 'Прочищаем БД'
			@job.update_stage(@stage_description.get_json) unless @job.nil?

			Rawfile.delete_all
	    Attachment.delete_all
	    Comment.delete_all    
	    Topic.delete_all     
	    Post.delete_all
	    Vgroup.delete_all

	    @job.update_progress unless @job.nil?
		end

		def logGroup(group_id, official_token = CONFIG[:OFFICIAL_TOKEN])
	    #byebug 
	    #sleep(10)
	   	
	    logGroupTopics(group_id)
	    #byebug
	    reconfigure_api_as_official_app(official_token)

	    fetchGroupWallPosts(group_id) 
  	end

		private

			# Returns VK API object
		  def vk
		    @vk ||= VkontakteApi::Client.new(@token)
		  end

		  # Reconfigures to pretend as official app in order to access group wall comments
		  # official_token - token from official app authorization
		  def reconfigure_api_as_official_app(official_token)
		    VkontakteApi.configure do |config|
		      config.app_id       =  CONFIG[:OFFICIAL_APP_ID] #'3682744'
		      config.redirect_uri =  CONFIG[:OFFICIAL_REDIRECT_URI]    #'http://oauth.vk.com/blank.html'    
		    end
		    @token = official_token
		    @vk = nil
		  end 

			def logGroupTopics(group_id)  
				@stage_description.stage_name = "Скачиваем обсуждения"
				@job.update_stage(@stage_description.get_json) unless @job.nil?

		    group = vk.groups.getById(group_id: group_id).first
		    #byebug
		    bytes = downloadPhotoAttachments(group)

		    society = Vgroup.new
		    society.json = group.to_json
		    society.vk_id = group[:id]
		    society.save

		    unless bytes.nil?
		      bytes.each { |key,value|
		        file = society.rawfiles.new
		        file.tag = key
		        file.data = value
		        file.save
		      }
		    end

		    #@friends = group.getBanned(group_id: group.gid)

		    raw_topics = vk.board.getTopics(group_id: group.id)
		    topics = raw_topics[:items]
		    cnt = raw_topics[:count]
		    @job.update_progress_max(cnt) unless @job.nil?
		    topics.each { |topic|
		    	@stage_description.stage_name = "Скачиваем обсуждение: #{topic.title}"
		    	@job.update_stage(@stage_description.get_json) unless @job.nil?
		      #t = Topic.new
		      t = society.topics.new
		      t.json = topic.to_json     
		      t.save

		      fetchBoardComments(t, group.id, topic.id)
		      sleep(REQUEST_DELAY)
		      @job.update_progress unless @job.nil?
		    }

		    @job.update_progress(step: -topics.size) unless @job.nil?
		    #TODO: Нужен ли рекурсивный вызов, если количество обсуждений больше мксимального числа обсуждений в ответе сервера?
		    #society
			end

		  def fetchGroupWallPosts(owner_id, offset = 0)
		  	@stage_description.stage_name = "Скачиваем посты на стене"
		  	@job.update_stage(@stage_description.get_json) unless @job.nil?

		    #byebug
		    #society = Vgroup.find(4)
		    society = Vgroup.order("id DESC").first
		    fetchSize = 100
		    raw_wall = vk.wall.get(owner_id: -owner_id, extended: 1, count: fetchSize, offset: offset)    
		    posts = raw_wall[:items]
		    profiles = raw_wall[:profiles]
		    realFetchSize = posts.size
		    @job.update_progress_max(realFetchSize) unless @job.nil?
		    posts.each {|post|
		    	@stage_description.stage_name = "Скачиваем пост: #{post.text}"
		    	@job.update_stage(@stage_description.get_json) unless @job.nil?
		      #byebug
		      #if post[:text].downcase.include? 'Самая эпич'
		      #byebug
		      #p = Post.new
		      p = society.posts.new
		      p.json = post.except(:attachments).to_json
		      p.save

		      logAttachments(p, post[:attachments]) if post.has_key? :attachments
		      #end
		      post_owner = getUserFromProfiles(profiles, post[:from_id])
		      reply_owner = getUserFromProfiles(profiles, post[:reply_owner_id])
		      comments_count = post[:comments][:count]
		      date = DateTime.strptime(post[:date].to_s,'%s')
		      text = post[:text]
		      #puts "#{date}, #{post_owner[:first_name]} #{post_owner[:last_name]}, comments: #{comments_count}: #{text}"
		      #byebug
		      fetchPostComments(p, owner_id, post[:id])
		      #break
		      #end
		      @job.update_progress unless @job.nil?
		    }
		    #byebug
		    if fetchSize == realFetchSize
		      # продолжаем фетчить
		      sleep(REQUEST_DELAY)
		      fetchGroupWallPosts(owner_id, offset + fetchSize)
		      @job.update_progress(step: -posts.size) unless @job.nil?
		    end
		  end

		  def logComments(commentable, raw_comments)
		    comments = raw_comments[:items]
		    profiles = raw_comments[:profiles]
		    n = 1
		    comments.each{|comment|
		    	@stage_description.substage_name = "Комментарий #{n} из #{comments.size}"
		    	@job.update_stage(@stage_description.get_json) unless @job.nil?
		      #ctext = comment[:text][0,30]
		      #cuser = getUserFromProfiles(profiles, comment[:from_id])

		      #byebug
		      c = commentable.comments.new
		      c.json = comment.except(:attachments).to_json
		      c.save

		      logAttachments(c, comment[:attachments]) if comment.has_key? :attachments
		      #puts "#{cuser[:first_name]} #{cuser[:last_name]}: #{ctext}" unless cuser.nil?

		      n = n + 1
		    }
		    last_comment_id = (comments.nil? || comments.size == 0) ? 0 : comments.last[:id]
		  end

		  def fetchPostComments(post, owner_id, post_id, start_comment_id = 0)
		    #byebug
		    fetchSize = 100
		    raw_comments = vk.wall.getComments(owner_id: -owner_id, post_id: post_id, extended: 1, start_comment_id: start_comment_id, count: fetchSize, offset: (start_comment_id == 0 ? 0 : 1) )
		    realFetchSize = raw_comments[:items].size
		    last_comment_id = logComments(post, raw_comments)    
		    if fetchSize == realFetchSize
		      # продолжаем фетчить
		      fetchPostComments(post, owner_id, post_id, last_comment_id)
		    end
		  end

		  def fetchBoardComments(topic, group_id, topic_id, start_comment_id = 0)
		    fetchSize = 100
		    raw_comments = vk.board.getComments(group_id: group_id, topic_id: topic_id, extended: 1, start_comment_id: start_comment_id, count: fetchSize, offset: (start_comment_id == 0 ? 0 : 1) )
		    realFetchSize = raw_comments[:items].size
		    last_comment_id = logComments(topic, raw_comments)    
		    if fetchSize == realFetchSize
		      # продолжаем фетчить
		      fetchBoardComments(topic, group_id, topic_id, last_comment_id)
		    end
		  end

		  def getUserFromProfiles (profiles, user_id)
		    user = profiles.select {|profile| profile.id == user_id}.first
		    user ||= {first_name: 'Администратор', last_name: 'группы'}
		  end

		  def logAttachments(attachmentable, attachments)
		    attachments.each{ |att|
		      case att[:type]
		      when 'video'
		        getVideoAttachment(attachmentable, att) 
		      when 'audio'
		        logSimpleAttachment(attachmentable, att)
		      when 'doc'
		        logSimpleAttachment(attachmentable, att)
		      when 'photo'
		        getPhotoAttachment(attachmentable, att) 
		      when 'link'
		        logSimpleAttachment(attachmentable, att)
		      when 'sticker'
		        logSimpleAttachment(attachmentable, att)
		      else
		        getOtherAttachment(attachmentable, att)
		      end

		      #puts att[:type] if att[:type] != 'video' && att[:type] != 'audio' 
		      #attachment = attachmentable.attachments.new
		      #attachment.json = 

		      sleep(REQUEST_DELAY)
		    }
		  end

		  def getOtherAttachment(attachmentable, raw_attachment)
		    #byebug
		    raise "Other Attachment type encountered"
		  end

		  def getVideoAttachment(attachmentable, raw_attachment)
		    #byebug
		    attachment = raw_attachment[:video]
		    raw_video = vk.video.get(extended: 1, owner_id: attachment[:owner_id], videos: "#{attachment[:owner_id]}_#{attachment[:id]}_#{attachment[:access_key]}")
		    raw_video[:items].each { |item|
		      bytes = downloadPhotoAttachments(item) 
		      logVideoAttachment(attachmentable, item, bytes)
		    }
		    #byebug
		  rescue VkontakteApi::Error => e
		    raise "getVideoAttachment: error_code != 15" if e.error_code != 15    
		  end


		  def getPhotoAttachment(attachmentable, raw_attachment)
		    #byebug   
		    bytes = downloadPhotoAttachments(raw_attachment[raw_attachment[:type]]) 
		    # добавим ссылки на файлы в исходный массив
		    logSimpleAttachment(attachmentable, raw_attachment, bytes)    
		  end

		  def logSimpleAttachment(attachmentable, raw_attachment, bytes = nil)
		    #byebug if raw_attachment[:type] == 'photo'
		    #byebug
		    attachment = raw_attachment[raw_attachment[:type]]

		    a = attachmentable.attachments.new
		    a.json = attachment.to_json
		    a.attachment_type = raw_attachment[:type]
		    a.save

		    unless bytes.nil?
		      bytes.each { |key,value|
		        file = a.rawfiles.new
		        file.tag = key
		        file.data = value
		        file.save
		      }
		    end
		  end

		  def logVideoAttachment(attachmentable, attachment, bytes = nil)
		    #byebug if raw_attachment[:type] == 'photo'
		    #byebug

		    a = attachmentable.attachments.new
		    a.json = attachment.to_json
		    a.attachment_type = 'video'
		    a.save

		    unless bytes.nil?
		      bytes.each { |key,value|
		        file = a.rawfiles.new
		        file.tag = key
		        file.data = value
		        file.save
		      }
		    end
		  end

		  def downloadPhotoAttachments(fileable)
		    bytes = {}
		    photo_keys = fileable.keys.select { |key| key.to_s.start_with? 'photo_'}
		    photo_keys.each { |key|
		      #byebug
		      bytes[key] = downloadPhoto(fileable[key])
		    }
		    bytes
		  end

	  	def faradayConn
		    @faradayConn ||= Faraday.new(:url => 'http://vk.com') do |c|
		      c.use Faraday::Request::UrlEncoded  # encode request params as "www-form-urlencoded"
		      c.use Faraday::Response::Logger     # log request & response to STDOUT
		      c.use Faraday::Adapter::NetHttp     # perform requests with Net::HTTP
	    	end

    		@faradayConn
  		end

		  def downloadPhoto(url)
		    response = faradayConn.get(url)
		    response.body
		    #file = RawFile.new(data: response.body)
		    #file.save
		    #file.id
		  end

	end

end