require 'bcrypt'
require 'sequel'

use Rack::Session::Cookie, secret: "onaunfntoyfunt"

class Application
  def call(env)
    @env = env
    if authenticated?
      user = DB[:users][id: session['user_id']]
      body = "Welcome, #{user[:username]} | <a href=\"/logout\">Logout</a>"
    else
      body = '<a href="/login">Login</a> | <a href="/signup">Sign up</a>'
    end
    [ 200, { 'Content-Type' => 'text/html' }, [body]]
  end

  def authenticated?
    session['user_id']
  end

  def session
    @env['rack.session']
  end
end

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  String :username
  String :encrypted_password
end

class User
  def self.register(params)
    DB[:users].insert(username: params['username'],
                      encrypted_password: BCrypt::Password.create(params['password']))
  end
end

class SignUp
  def call(env)
    req = Rack::Request.new(env)

    if req.post?
      User.register(req.params)
      p DB[:users].first
      [ 301, { 'Location' => '/login' }, [] ]
    else
      [ 200, { 'Content-Type' => 'text/html' }, [File.read('signup.html')]]
    end
  end
end

class Login
  def call(env)
    req = Rack::Request.new(env)

    if req.post?
      user = DB[:users][username: req.params['username']]
      if user && BCrypt::Password.new(user[:encrypted_password]) == req.params['password']
        env['rack.session']['user_id'] = user[:id]
        [ 301, { 'Location' => '/' }, [] ]
      else
        [ 301, { 'Location' => '/login' }, [] ]
      end
    else
      [ 200, { 'Content-Type' => 'text/html' }, [File.read('login.html')]]
    end
  end
end

map '/signup' do
  run SignUp.new
end

map '/login' do
  run Login.new
end

map '/logout' do
  run -> (env) do
    env['rack.session'].delete('user_id')
    [ 301, { 'Location' => '/' }, []]
  end
end

run Application.new
