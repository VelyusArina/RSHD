# RSHD
## Лабораторная работа № 2
### Вариант: 33160

### Задание: 
Цель работы - на выделенном узле создать и сконфигурировать новый кластер БД Postgres, саму БД, табличные пространства и новую роль, а также произвести наполнение базы в соответствии с заданием. Отчёт по работе должен содержать все команды по настройке, скрипты, а также измененные строки конфигурационных файлов.

Способ подключения к узлу из сети Интернет через helios:
ssh -J s308478@helios.cs.ifmo.ru:2222 postgres5@pg155

Способ подключения к узлу из сети факультета:
ssh postgres5@pg155

Номер выделенного узла pg155, а также логин и пароль для подключения Вам выдаст преподаватель.

#### Этап 1. Инициализация кластера БД
-	Директория кластера: $HOME/gkt53
-	Кодировка: ANSI1251
-	Локаль: английская
-	Параметры инициализации задать через аргументы команды
#### Этап 2. Конфигурация и запуск сервера БД
-	Способы подключения: 1) Unix-domain сокет в режиме peer; 2) сокет TCP/IP, только localhost
-	Номер порта: 9160
-	Способ аутентификации TCP/IP клиентов: по имени пользователя
-	Остальные способы подключений запретить.
-	Настроить следующие параметры сервера БД:
    -	max_connections
    -	shared_buffers
    -	temp_buffers
    -	work_mem
    -	checkpoint_timeout
    -	effective_cache_size
    -	fsync
    -	commit_delay
      
Параметры должны быть подобраны в соответствии со сценарием OLAP:
10 одновременных пользователей, пакетная запись/чтение данных по 256МБ.

-	Директория WAL файлов: $HOME/fzi37
-	Формат лог-файлов: .csv
-	Уровень сообщений лога: INFO
-	Дополнительно логировать: попытки подключения и завершение сессий
#### Этап 3. Дополнительные табличные пространства и наполнение базы
-	Создать новые табличные пространства для различных таблиц: $HOME/fip41, $HOME/upc28, $HOME/tqh1
-	На основе template0 создать новую базу: bestgoldlab
-	Создать новую роль, предоставить необходимые права, разрешить подключение к базе.
-	От имени новой роли (не администратора) произвести наполнение ВСЕХ созданных баз тестовыми наборами данных. ВСЕ табличные пространства должны использоваться по назначению.
-	Вывести список всех табличных пространств кластера и содержащиеся в них объекты.
  
### Выполнение: 
#### Этап 1. Инициализация кластера БД
```
mkdir -p $HOME/gkt53
initdb -D $HOME/gkt53 --locale=ru_RU.CP1251 --username=postgres5 -E WIN1251
pg_ctl -D /var/db/postgres5/gkt53 -l start_logserver.log start
```
#### Этап 2. Конфигурация и запуск сервера БД
##### Файл pg_hba.conf
```
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            ident
# IPv6 local connections:
host    all             all             ::1/128                 reject
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     reject
host    replication     all             127.0.0.1/32            reject
host    replication     all             ::1/128                 reject

```
##### Файл postgresql.conf
```
listen_addresses = 'localhost'
port = 9160
max_connections = 10
shared_buffers = 512MB 
temp_buffers = 256MB
work_mem = 256MB
checkpoint_timeout = 5min 
effective_cache_size = 1GB 
fsync = on 
commit_delay = 0
wal_directory = '$HOME/fzi37'
log_destination = 'csvlog'
log_min_messages = info
logging_collector = on
log_connections = on
log_disconnections = on
```
##### Описание параметров:
-	max_connections - определяет максимальное количество одновременных соединений
-	shared_buffers - размер выделенной оперативной памяти для кэширования данных в памяти (25-40%)
-	temp_buffers - максимальное число временных буферов для каждого сеанса. Если сеанс не задействует временные буферы, то для него хранятся только дескрипторы буферов, которые занимают около 64 байт
-	work_mem - Объём памяти, для внутренних операций сортировки и хеш-таблиц, до того как будут задействованы временные файлы на диске (по умолчанию 4МБ)
-	checkpoint_timeout - максимальное время между автоматическими контрольными точками в WAL.
-	effective_cache_size - предоставляет оценку памяти, доступной для кэширования диска.
-	fsync - сервер PostgreSQL старается добиться, чтобы изменения были записаны на диск физически, выполняя системные вызовы fsync()
-	-	commit_delay – пауза перед выполнением сохранение WAL.
#### Этап 3. Дополнительные табличные пространства и наполнение базы
```
mkdir $HOME/fip41
mkdir $HOME/upc28
mkdir $HOME/tqh1
#Создание новой базы данных на основе template0
createdb -T template0 bestgoldlab -p 9160
psql -U postgres5 -d bestgoldlab -p 9160 -h 127.0.0.1
```
##### psql
```
#Создать новую роль, предоставить необходимые права, разрешить подключение к базе.
CREATE ROLE bestgoldlab1 WITH LOGIN PASSWORD '1234'
GRANT ALL PRIVILEGES ON DATABASE bestgoldlab TO bestgoldlab1;
GRANT ALL PRIVILEGES ON TABLESPACE fip41 TO bestgoldlab1;
GRANT ALL PRIVILEGES ON TABLESPACE upc28 TO bestgoldlab1;
GRANT ALL PRIVILEGES ON TABLESPACE tqh1 TO bestgoldlab1;
```
```
CREATE TABLE fip41_table (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100)
) TABLESPACE fip41;

CREATE TABLE upc28_table (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100)
) TABLESPACE upc28;

CREATE TABLE tqh1_table (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100)
) TABLESPACE tqh1;

INSERT INTO fip41_table (data)
VALUES
    ('Data 1 for fip41_table'),
    ('Data 2 for fip41_table'),
    ('Data 3 for fip41_table');

INSERT INTO upc28_table (data)
VALUES
    ('Data 1 for upc28_table'),
    ('Data 2 for upc28_table'),
    ('Data 3 for upc28_table');

INSERT INTO tqh1_table (data)
VALUES
    ('Data 1 for tqh1_table'),
    ('Data 2 for tqh1_table'),
    ('Data 3 for tqh1_table');
```
```
SELECT * FROM fip41_table;
SELECT * FROM upc28_table;
SELECT * FROM tqh1_table;
```
##### Запрос: вывести таблицы и пользовательские пространства
```
select tablename, tablespace
from pg_tables
where schemaname='public';
```
