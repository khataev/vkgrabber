VkontakteApi.configure do |config|
  # Authorization parameters (not needed when using an external authorization):
  config.app_id       = CONFIG[:APP_ID] # '5149030' 
  config.app_secret   = CONFIG[:APP_SECRET] # 'zCM50gqX04S9jN6mKZlM'
  config.redirect_uri = CONFIG[:REDIRECT_URI] # 'http://7thheaven.myds.me:4000/callback'

  #config.app_id       = '3682744' #ENV['APP_ID']
  #config.redirect_uri = 'http://oauth.vk.com/blank.html' #ENV['REDIRECT_URI']
  #http://oauth.vk.com/blank.html#access_token=5ff86ac2eba628c887a6380fc33bf48cf56727ed93572207e3ec4389fa8b60f7d4460c836f670369387f0&expires_in=0&user_id=35549534
  #oauth.vk.com/authorize?client_id=3682744&v=5.7&scope=docs,wall,audio,video,offline&redirect_uri=http://oauth.vk.com/blank.html&display=page&response_type=token

  # используемая версия API
  config.api_version = '5.40'

  # Faraday adapter to make requests with:
  # config.adapter = :net_http
  
  # Logging parameters:
  # log everything through the rails logger
  config.logger = Rails.logger
  
  # log requests' URLs
  config.log_requests = true
  
  # log response JSON after errors
  config.log_errors = true
  
  # log response JSON after successful responses
  config.log_responses = false
end
