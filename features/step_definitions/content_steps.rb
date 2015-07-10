То(/^я вижу текст "([^"]*)"$/) do |text|
  expect(@response.body).to have_content text
end

То(/^я вижу текст:$/) do |text_data|
  text_data.hashes.each do |text_row|
    expect(@response.body).to have_content text_row[:text]
  end
end

То(/^я вижу кнопку "([^"]*)"$/) do |text|
  expect(@response.body).to have_selector(:link_or_button, text)
end

То(/^я вижу (\d+) кнопки "([^"]*)"$/) do |number, text|
  expect(@response.body).to have_selector(:link_or_button, text, count: number)
end
