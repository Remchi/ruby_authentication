# require 'base64'

# class Application
#   def call(env)
#     @env = env
#     if authenticated?
#       [ 200, {}, [ "authenticated" ]]
#     else
#       [ 401, { 'WWW-Authenticate' => 'Basic', 'Content-Length' => '0'}, []]
#     end
#   end

#   def authenticated?
#     header = @env['HTTP_AUTHORIZATION']
#     return false unless header
#     credentials = header.split(' ')[1]
#     credentials == Base64.encode64('a:b').strip
#   end
# end

# run Application.new

class Application
  def call(env)
    [ 200, {}, ['hi']]
  end
end

use Rack::Auth::Basic do | username, password |
  username == 'aa' && password == 'bb'
end

run Application.new
