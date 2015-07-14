ENV['RACK_ENV'] = 'test'

require 'rack/test'
require 'rspec/expectations'
require 'capybara/cucumber'
require 'pry'

require File.expand_path '../../../server.rb', __FILE__

Capybara.app = CoffeeServer.app

class CoffeeServerWorld
  include Rack::Test::Methods
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers

  def app; CoffeeServer.app; end
end

World do
  CoffeeServerWorld.new
end

Dotenv.load!
Mongoid.load!("config/mongoid.yml", :test)
