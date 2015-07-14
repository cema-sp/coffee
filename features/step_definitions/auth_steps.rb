Пусть(/^я аутенфицированный пользователь$/) do
  module CoffeeServerHelpers
    def authorized?; true; end
  end

  digest_authorize ENV['admin_login'], ENV['admin_password']
  # page.driver.browser.digest_authorize ENV['admin_login'], ENV['admin_password']
end

То(/^я получаю ошибку авторизации$/) do
  expect(page.status_code).to eq 401
end
