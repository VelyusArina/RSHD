
pw_dir=$(pwd)

cd ~

#Запустить БД
pg_ctl start -D gkt53

rm -r ./backup/*

#создать первоначальную резервную копию
pg_basebackup -F tar -h localhost -p 9160 -D ./backup -P -X stream

echo "Скрипт создания резервной копии завершил работу"

cd $pw_dir