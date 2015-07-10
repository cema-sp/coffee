Когда(/^я открываю сайт$/) do
  @response = page.request '/'
end

Когда(/^я открываю путь "([^"]*)"$/) do |path|
  @response = page.request path
end
