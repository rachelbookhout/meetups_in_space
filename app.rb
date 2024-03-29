require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  erb :index
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end


get'/meetups' do
  @meetups = Meetup.all.order(name: :asc)
  erb :'meetups/index'
end

get '/meetups/new' do
  if signed_in? ==false
    flash[:notice] = "Please sign in to add a meetup"
    redirect '/'
  end
erb :'meetups/new'
end


post '/meetups/new' do
  @meetup = Meetup.new(params[:meetup])
  if @meetup.save == false
    flash[:notice] = "Please fill out all forms!"
    redirect '/meetups/new'
  else
    flash[:notice] = "You have successfully created a meetup"
    redirect "/meetups/#{@meetup.id}"
  end
end

get '/meetups/:id' do
@meetup = Meetup.find(params[:id])
@members = Members.where(meetup_id: "#{@meetup.id}")
erb :'meetups/show'
end

post '/meetups/:id' do
@meetup = Meetup.find(params[:id])
if signed_in? == false
    flash[:notice] = "Please sign in to join a meetup"
    redirect '/'
else
  @member = Members.new(user_id: current_user.id, role: "member", meetup_id: @meetup.id )
  @member.save
  flash[:notice] = "You have successfully became a member of this group!"
  redirect "/meetups/#{@meetup.id}"
end
end





