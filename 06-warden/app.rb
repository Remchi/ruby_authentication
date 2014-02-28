require 'sinatra'
require 'warden'
require 'sequel'
require 'bcrypt'

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  String :username
  String :encrypted_password
end

pass = BCrypt::Password.create('pass')
DB[:users].insert( username: 'test', encrypted_password: pass )

class User
  def self.get(id)
    DB[:users][id: id]
  end

  def self.authenticate(user, password)
    BCrypt::Password.new(user[:encrypted_password]) == password
  end
end

class SinatraApp < Sinatra::Base
  use Rack::Session::Cookie, secret: "ento;wnfont"


  use Warden::Manager do |config|
    config.scope_defaults(:default,
                          strategies: [ :password ],
                          action: 'login')
    config.failure_app = self

    config.serialize_into_session { |user| user[:id] }
    config.serialize_from_session { |id| User.get(id) }
  end

  Warden::Manager.before_failure do |env, opts|
    env['REQUEST_METHOD'] = 'GET'
  end

  Warden::Strategies.add(:password) do
    def authenticate!
      user = DB[:users][username: params['username']]
      if user && User.authenticate(user, params['password'])
        success!(user)
      else
        fail!
      end
    end
  end

  get '/' do
    "Main page"
  end

  get '/login' do
    send_file "login.html"
  end

  post '/login' do
    env['warden'].authenticate!
    redirect '/'
  end

  get '/logout' do
    env['warden'].logout
    redirect '/login'
  end

  get '/secret' do
    env['warden'].authenticate!
    "Secret page"
  end
end

