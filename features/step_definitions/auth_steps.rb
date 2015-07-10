Пусть(/^я аутенфицированный пользователь$/) do
  page.digest_authorize 'admin', CoffeeServer::Admin.settings.admin_password
end

То(/^я получаю ошибку авторизации$/) do
  expect(@response.status).to eq 401
end
