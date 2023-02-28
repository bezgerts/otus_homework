# MySQL

## Запуск docker-compose

`docker-compose up`

## Запуск бенчмароков sysbench

После запуска docker-compose необходимо зайти в контейнер `otusdb`, для этого нужно выполнить следующие команды:

- `docker container ls`
- `docker exec -it <CONTAINER_ID> /bin/bash`

В контейнере необходимо выполнить команду:

`sh sysbench.sh &> report.txt`

Дождаться завершения выполнения команды и открыть файл с результатом при помощи команды:

`cat report.txt`
 
Пример в файле  report.txt (src/mysql/report.txt).