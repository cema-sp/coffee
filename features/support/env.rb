require 'rack/test'
require 'rspec/expectations'
require 'capybara/cucumber'

require File.expand_path '../../../server.rb', __FILE__

Mongoid.load!("mongoid.yml")

Capybara.app = CoffeeServer.app

include Rack::Test::Methods
