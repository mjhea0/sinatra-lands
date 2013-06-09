# app.rb

require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

enable :sessions

class Email < ActiveRecord::Base
  validates :email, presence: true, length: { minimum: 5 }
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/, :on => :create
end

helpers do
  def title
    if @title
      "#{@title}"
    else
      "Welcome."
    end
  end
    def protected!
    response['WWW-Authenticate'] = %(Basic realm="SunnyDirtRoad Administration") and \
    throw(:halt, [401, "Not authorized\n"]) and \
    return unless authorized?
  end
  def authorized?
    return false unless ADMIN_USERNAME && ADMIN_PASSWD
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ADMIN_USERNAME, ADMIN_PASSWD]
  end
end

get "/" do
  @title = "Welcome."
  erb :"index"
end

post "/" do
  @email = Email.new(:email => params[:email])
  if @email.save
    redirect "/", :notice => 'Thanks!'
  else
    redirect "/", :error => 'Something went wrong. Try again.'
  end
end

get '/responses' do
  protected!
  @title = 'Check responses'
  @emails = Email.order("created_at DESC")
  erb :responses
end