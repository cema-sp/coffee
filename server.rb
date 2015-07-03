require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'
require './helpers'

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

    before do
      content_type 'application/vnd.api+json;charset=utf-8'
    end

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
      before do
        content_type 'application/vnd.api+json;charset=utf-8'

        halt_request(406,
          "Invalid Accept header: #{request.accept}"
          ) unless request.accept? 'application/vnd.api+json'

        halt_request(415,
          "Invalid Content-Type header: #{request.env['HTTP_CONTENT_TYPE']}"
          ) if ((!request.env.has_key?('HTTP_CONTENT_TYPE') ||
            request.env['HTTP_CONTENT_TYPE'] !=
              'application/vnd.api+json;charset=utf-8'))
      end

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

  # Point Model

  class Point
    include Mongoid::Document

    field :address, type: String, default: ''
    field :coordinates, type: Hash
    field :predefined, type: Boolean, default: false
    field :votes, type: Integer, default: 1
    field :comment, type: String, default: ''

    validates_presence_of :coordinates
    validate :coordinates_keys_validation
    validates_numericality_of :votes, equal_to: 1, message: '"votes" should equal 1'
    validates_format_of :predefined, with: /false/, message: '"predefined" should be false'

    # Custom validations

    def coordinates_keys_validation
      if coordinates.present?
        unless coordinates.length == 2 
          errors.add(:coordinates, 'coordinates should contain both lat & lon')
        end
        coordinates.each do |key, _|
          unless [:lat, :lon, 'lat', 'lon'].include?(key)
            errors.add(:coordinates, 'coordinates should contain lat & lon')
          end
        end
      end
    end
  end
end
