GetUserJob = Struct.new(:token, :uid) do
  def perform
    sleep 10
    ReturnValueKeeper.return_value = vkgg.get_user_json(uid)
  end

  def vkgg
    @vk ||= VkHelper::VkGroupGrabber.new(token)
  end
end