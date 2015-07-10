Пусть(/^имеются точки с комментариями:$/) do |points_data|
  points_data.hashes.each do |row|
    CoffeeServer::Point
      .create(coordinates: { lat: 1, lon: 2}, comment: row[:comment])
  end
end
