# require 'pry'

То(/^я вижу текст "([^"]*)"$/) do |text|
  expect(@response.body).to have_content text
end
