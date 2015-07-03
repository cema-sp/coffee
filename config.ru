require 'pry'
require './server'

Mongoid.load!("mongoid.yml")

# binding.pry

run CoffeeServer.app
