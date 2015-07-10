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
end
