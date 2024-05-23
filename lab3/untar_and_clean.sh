pw_dir=$(pwd)

cd backup

mkdir fzi37
cd fzi37/
tar xf ../16394.tar

cd ..

mkdir upc28
cd upc28/
tar xf ../16395.tar

cd ..

mkdir tqh1
cd tqh1/
tar xf ../16399.tar

cd ..

mkdir gkt53
cd gkt53
tar xf ../base.tar

cd ..

cd pg_wal
tar xf ../../pg_wal.tar

cd ..

rm -r *.tar

cd ../..

#скопировать на резервный узел
rsync -avz ./backup/ postgres1@pg193:~/reserve_backup/

echo "Скрипт разархивирования резервной копии завершил работу"

cd $pw_dir
