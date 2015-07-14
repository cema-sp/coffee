Когда(/^я открываю сайт$/) do
  visit '/'
end

Когда(/^я открываю путь "([^"]*)"$/) do |path|
  visit path
end
