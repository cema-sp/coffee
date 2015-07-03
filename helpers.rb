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
end
