require 'rack/test'
require 'rspec/expectations'
require 'capybara/cucumber'
require 'pry'

require File.expand_path '../../../server.rb', __FILE__

Mongoid.load!("mongoid.yml", :test)

Capybara.app = CoffeeServer.app

include Rack::Test::Methods
