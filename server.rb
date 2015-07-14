require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/reloader'
require 'dotenv'
require 'mongoid'
require 'slim'
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
    configure :development do
      register Sinatra::Reloader
    end

    get '/?' do
      'Здесь будет карта'
    end
  end

  # Administrative panel
  class Admin < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    helpers CoffeeServerHelpers

    set :views, (File.expand_path '../clients/admin', __FILE__)
    set :public_folder, (File.expand_path '../clients/admin/public', __FILE__)

    before { protected! }

    get '/?' do
      slim :index
    end
  end

  # API proxy
  class API < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

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
    configure :development do
      register Sinatra::Reloader
    end

    register Sinatra::Namespace
    helpers CoffeeServerHelpers

    set :version, '1'

    namespace '/points', provides: 'application/vnd.api+json' do
      before { check_header }

      # #index
      get '' do
        points = Point.all

        [ 200, {}, { points: points }.to_json ]
      end

      # #show
      get '/:id' do
        begin
          point = Point.find(params[:id])

          [ 200, {'Location' => "/#{point._id}"}, point.to_json ]
        rescue Exception => error
          halt_request(404, error.message)
        end
      end

      # #create
      post '/?' do
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

      # #update
      patch '/:id' do
        begin
          request.body.rewind
          point_raw = JSON.parse request.body.read
          point_raw.delete("_id")

          point = Point.find(params[:id])
          point.update_attributes!(point_raw)

          [ 200, {'Location' => "/#{point._id}"}, point.to_json ]
        rescue Mongoid::Errors::DocumentNotFound => error
          halt_request(404, error.message)
        rescue Exception => error
          halt_request(403, error.message)
        end
      end

      # #delete
      delete '/:id' do
        begin
          point = Point.find(params[:id])

          point.destroy

          [ 200, {}, {}.to_json ]
        rescue Mongoid::Errors::DocumentNotFound => error
          halt_request(404, error.message)
        rescue Exception => error
          halt_request(403, error.message)
        end
      end
    end

    # Handle invalid Accept header
    namespace '/points' do
      before { check_header }
    end

    # Handle invalid object
    get '/?*' do
      halt_request(404, "Invalid API object: #{params['captures']}")  
    end
  end
end
