require 'sinatra'
require 'json'
require 'sequel'
require 'bcrypt'

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  String :username
  String :encrypted_password
  String :authentication_token
end

pass = BCrypt::Password.create('pass')
DB[:users].insert( username: 'test', encrypted_password: pass )

post '/login' do
  content_type :json

  user = DB[:users][username: params['username']]
  if user && BCrypt::Password.new(user[:encrypted_password]) == params['password']
    auth_token = loop do
      token = SecureRandom.urlsafe_base64(15)
      break token unless DB[:users][authentication_token: token]
    end
    DB[:users].where(username: params['username']).update(authentication_token: auth_token)
    p DB[:users].first
    { auth_token: auth_token }.to_json
  else
    status 401
  end
end

get '/' do
  content_type :json
  { content: "main page" }.to_json
end

get '/secret' do
  content_type :json
  if authenticated?(env['HTTP_TOKEN'])
    { content: "secret" }.to_json
  else
    status 401
  end
end

def authenticated?(token)
  token && DB[:users][authentication_token: token]
end
