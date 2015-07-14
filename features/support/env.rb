ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'rspec/expectations'
require 'capybara/cucumber'
require 'pry'

require File.expand_path '../../../server.rb', __FILE__

Mongoid.load!("config/mongoid.yml", :test)

Capybara.app = CoffeeServer.app

include Rack::Test::Methods
Dotenv.load!
