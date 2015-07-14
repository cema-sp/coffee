То(/^я вижу текст "([^"]*)"$/) do |text|
  expect(page.body).to have_content text
end

То(/^я вижу текст:$/) do |text_data|
  text_data.hashes.each do |text_row|
    expect(page.body).to have_content text_row[:text]
  end
end

То(/^я вижу кнопку "([^"]*)"$/) do |text|
  expect(page.body).
    to have_xpath(%(//input[@type="button"][@alt="#{text}"]))
end

То(/^я вижу (\d+) кнопки "([^"]*)"$/) do |number, text|
  expect(page.body).
    to have_xpath(%(//input[@type="button"][@alt="#{text}"]), count: number)
end
