# Приложение Coffee
## Описание

## Функциональные возможности
### Пользователь

Фильтр по рейтингу
Фильтр по бренду (системные)
Бренд в документах
Индекс по бренду

### Администратор

Добавление локаций
Добавление из csv
Отчет по оценкам с фильтром по системным локациям

## Модель данных

СУБД - MongoDB

Данные о точках хранятся в документах следующей структуры:  

~~~json
{
  "points": [
    {
      "_id": "",
      "coordinates": {
        "lat": 120.1324452,
        "lon": 61.8034212
      },
      "address": "",
      "predefined": true,
      "votes": 0,
      "comment": "На втором этаже ТЦ"
    }
  ]
}
~~~

Соединение с БД: `mongo --shell 192.168.122.247:27017/coffee-dev`.  
Удаление БД: `db.dropDatabase()`

## API
### Описание
Используется [JSON REST API][json].  

Заголовок запроса должен содержать:  

| Заголовок    | Значение                               |  
| :--          | :--                                    |  
| Content-Type | application/vnd.api+json;charset=utf-8 |  
| Accept       | application/vnd.api+json               |  

Заголовок ответа сервера содержит:  

| Заголовок    | Значение                               |  
| :--          | :--                                    |  
| Content-Type | application/vnd.api+json;charset=utf-8 |  

### Ошибки

| Код | Ошибка                      | Описание                                            |  
| --: | :--                         | :--                                                 |  
| 404 | Invalid API version         | Ошибочная версия API                                |  
| 404 | Invalid API path            | Ошибочный путь запроса                              |  
| 406 | Invalid Accept header       | Не правильно задан заголовок "Accept" запроса       |  
| 415 | Invalid Content-Type header | Не правильно задан заголовок "Content-Type" запроса |  

### points
#### POST /points (#create)

Ошибки:  

| Код | Ошибка                      | Описание                                            |  
| --: | :--                         | :--                                                 |  
| 403 | {errors: [...]}         | Ошибки запроса                                |  




[json]: http://jsonapi.org/ "jsonapi.org"