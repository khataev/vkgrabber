# encoding: utf-8
class SessionsController < ApplicationController
  def new
    session[:token] = nil
    srand
    session[:state] ||= Digest::MD5.hexdigest(rand.to_s)
    
    @vk_url = VkontakteApi.authorization_url(scope: [:wall, :friends, :groups, :offline, :notify, :video, :audio, :docs], state: session[:state])
  end
  
  def callback
    redirect_to root_url, alert: 'Ошибка авторизации, попробуйте войти еще раз.' and return if session[:state].present? && session[:state] != params[:state]
    #redirect_to main_url, alert: 'Ошибка авторизации, попробуйте войти еще раз.' and return if session[:state].present? && session[:state] != params[:state]
    

    @vk = VkontakteApi.authorize(code: params[:code])
    session[:token] = @vk.token
    session[:vk_id] = @vk.user_id
    
    redirect_to root_url
    #redirect_to main_url
  end
  
  def destroy
    session[:token] = nil
    session[:vk_id] = nil
    
    redirect_to root_url
  end
end