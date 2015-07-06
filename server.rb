require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'
require './helpers'
require './point'

module CoffeeServer
  # Main Application
  class << self
    def app
      Rack::URLMap.new({
        '/' => CoffeeServer::Public,
        '/admin' => CoffeeServer::Admin,
        '/api' => CoffeeServer::API,
        '/api/v1' => CoffeeServer::API_v1
      })
    end
  end

  # Public available part
  class Public < Sinatra::Base
    get '/' do
      'Здесь будет карта'
    end
  end

  # Administrative panel
  class Admin < Sinatra::Base
    set :realm, 'Coffee Server'
    set :secret, 'secretkey'
    set :admin_password, 'password'

    get '/' do
      'Здесь будет интерфейс администратора'
    end

    def self.new(*)
      app = Rack::Auth::Digest::MD5.new(super) do |username|
        {'admin' => settings.admin_password}[username]
      end
      app.realm = settings.realm
      app.opaque = settings.secret
      app
    end
  end

  # API proxy
  class API < Sinatra::Base
    helpers CoffeeServerHelpers

    set :versions, ['1']

    before { check_header }

    get /\A\/v([\d+]\.*[\d+]).*/ do
      if settings.versions.include?(params['captures'].first)
        pass
      else
        halt_request(404, "Invalid API version: #{params['captures'].first}")
      end
    end

    get /\A\/[^v]/ do
      halt_request(404, 'Invalid API path')
    end
  end

  # API version 1
  class API_v1 < Sinatra::Base
    register Sinatra::Namespace
    helpers CoffeeServerHelpers

    set :version, '1'

    namespace '/points' do
      before { check_header }

      get '', provides: 'application/vnd.api+json' do
        'points'
      end

      post '', provides: 'application/vnd.api+json' do
        begin
          request.body.rewind
          point_raw = JSON.parse request.body.read
          point_raw.delete("_id")
          point = Point.new(point_raw)
          point.save!

          [ 201, {'Location' => "/#{point._id}"}, point.to_json ]
        rescue Exception => error
          halt_request(403, error.message)
        end
      end
    end


    get '/*' do
      "Invalid API object"  
    end
  end
end
