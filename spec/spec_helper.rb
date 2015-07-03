require File.expand_path '../../server.rb', __FILE__

require 'rack/test'
require 'rspec'
require 'rspec/its'
require 'shoulda/matchers'
require 'database_cleaner'
require 'pry'
# require 'capybara/rspec'

ENV['RACK_ENV'] = 'test'

Mongoid.load!("mongoid.yml")

module RSpecMixin
  include Rack::Test::Methods
  def app() CoffeeServer.app; end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec

    with.library :active_record
    with.library :active_model
    # with.library :action_controller
  end
end
