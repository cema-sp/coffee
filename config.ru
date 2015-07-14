require 'pry'
require './server'

Mongoid.load!("config/mongoid.yml")

# binding.pry

run CoffeeServer.app
