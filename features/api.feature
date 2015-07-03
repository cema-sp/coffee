# language: ru

Функционал: API без авторизации

  Сценарий: Неверная версия API
    Когда я открываю путь "/api/v1000"
    То я вижу текст "Invalid API version"

  Сценарий: Неверный объект API
    Когда я открываю путь "/api/v1/lololo"
    То я вижу текст "Invalid API object"

  Сценарий: Получение точек (TODO)
    Когда я открываю путь "/api/v1/points"
    То я вижу текст "points"

# Функционал: API с авторизацией
  # Сценарий: Просмотр API с авторизацией
  #   Пусть я аутенфицированный пользователь
  #   Когда я открываю путь "/api/v1/points"
  #   То я вижу текст "points"
