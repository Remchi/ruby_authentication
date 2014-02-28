require 'sinatra'
require 'rest-client'
require 'json'
require 'sequel'

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  String :username
end

use Rack::Session::Cookie, secret: "ornetfount"

get '/login' do
  '<a href="https://github.com/login/oauth/authorize?client_id=25042e65e35126452984">Login with GitHub</a>'
end

get '/callback' do
  result = RestClient.post('https://github.com/login/oauth/access_token',
                           {
                             client_id: '25042e65e35126452984',
                             client_secret: 'bcfacbcac9244f37724dbccf6a81ecf5779d10fa',
                             code: params['code']
                           }, accept: :json)

  session[:access_token] = JSON.parse(result)['access_token']

  info = RestClient.get('https://api.github.com/user',
                        { params: { access_token: session[:access_token] } })

  username = JSON.parse(info)['login']

  unless DB[:users][username: username]
    DB[:users].insert( username: username )
  end

  p DB[:users].count
  
  redirect '/secret'
end

get '/secret' do
  redirect '/login' unless session[:access_token]
  "secret"
end

get '/logout' do
  session[:access_token] = nil
  redirect '/login'
end
