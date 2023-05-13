# Знакомство с MongoDB

## Запуск MongoDB

Запускаем MongoDB при помощи `docker-compose.yml` (src/mongodb/docker-compose.yml).

```bash
docker-compose up
```

## Команды docker-compose

Посмотреть все базы:

```bash
show dbs
```

Использовать определенную базу данных
```bash
use otus
```

Создать коллекцию:

```bash
db.createCollection("cars")
```

Удалить коллекцию:

```bash
db.getCollection("cars").drop();
```

Наполнить коллекцию данными:

```bash
# создание коллекции
db.createCollection("students")

# вставка значений в коллекцию по одному
db.students.insertOne( { _id: 1, student_name: "Arkadiy", age: 34 } )
db.students.insertOne( { _id: 2, student_name: "Maxim", age: 28 } )

# вставка сразу нескольких значений
db.students.insertMany([ { _id: 3, student_name: "Artem", age: 34 },
    { _id: 4, student_name: "Egor", age: 35} ])
```

Выборка данных:

```bash
# вывести все данные
db.students.find()

# вывести все в читаемом формате
db.students.find().pretty()

# вывести студента по идентификатору
db.students.find({"_id" : 2})

# вывести всех студентов с именем Arkadiy
db.students.find({"student_name": "Arkadiy"})

# вывести всех студентов старше 30 лет
db.students.find({"age" : {$gt: 30}})

# вывести всех студентов старше 30 лет или всех студентов с именем Maxim
db.students.find({$or:[{"age" : {$gt: 30}}, {"student_name": "Maxim"}]})
```

