require 'pry'
require './server'

Dotenv.load!
Mongoid.load!("config/mongoid.yml")

# binding.pry

run CoffeeServer.app
