use Rack::Session::Cookie, secret: "irnd;ufndto.ent[fnt"

class Application
  def call(env)
    @env = env
    
    text = authenticated? ? 'authenticated' : 'not authenticated'
    [200, {}, [ text ]]
  end

  def authenticated?
    session['user_id']
  end

  def session
    @env['rack.session']
  end
end

class Login
  def call(env)
    env['rack.session']['user_id'] = 1
    [ 301, { 'Location' => '/' }, [] ]
  end
end


map '/public' do
  run ->(env) do
    [ 200, {}, [ "public" ]]
  end
end

map '/secret' do
  run ->(env) do
    [ 200, {}, [ "secret" ]]
  end
end

map '/login' do
  run Login.new
end

map '/logout' do
  run ->(env) do
    env['rack.session'].delete('user_id')
    [ 301, { 'Location' => '/' }, [] ]
  end
end

run Application.new
