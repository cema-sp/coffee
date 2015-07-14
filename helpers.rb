module CoffeeServerHelpers
  def error_message(message)
    {errors: [message]}.to_json    
  end

  def halt_request(status, message)
    halt(
      status,
      {'Content-Type' => 'application/vnd.api+json;charset=utf-8'},
      error_message(message))   
  end

  def check_header
    content_type 'application/vnd.api+json;charset=utf-8'

    # binding.pry

    halt_request(406,
      "Invalid Accept header: #{request.accept}"
      ) unless request.accept? 'application/vnd.api+json'

    content_type = (
      if request.env.has_key?('HTTP_CONTENT_TYPE')
        request.env['HTTP_CONTENT_TYPE']
      elsif request.env.has_key?('CONTENT_TYPE')
        request.env['CONTENT_TYPE']
      else
        ''
      end
    )

    halt_request(415,
      "Invalid Content-Type header: #{request.env['HTTP_CONTENT_TYPE']}"
      ) if (content_type.downcase != 'application/vnd.api+json;charset=utf-8')
  end

  def protected!
    return if authorized?
    @auth = nil
    headers['WWW-Authenticate'] =
      %(Digest realm="#{ENV['realm']}",
        qop="auth,auth-int",
        nonce="12345",
        opaque="#{ENV['realm_secret']}")

    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Digest::Request.new(request.env)

    if @auth.provided? &&
      @auth.digest? &&
      @auth.params['username'] == ENV['admin_login']

      ha1 = Digest::MD5.hexdigest(
        "#{ENV['admin_login']}:#{ENV['realm']}:#{ENV['admin_password']}")
      ha2 = Digest::MD5.hexdigest(
        "#{request.env['REQUEST_METHOD']}:#{@auth.params['uri']}")
      expected_response = Digest::MD5.hexdigest(
        %(#{ha1}:#{@auth.params['nonce']}:#{@auth.params['nc']}:#{@auth.params['cnonce']}:#{@auth.params['qop']}:#{ha2}))

      expected_response == @auth.params['response']
    end
  end
end
