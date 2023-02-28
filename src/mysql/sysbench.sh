#!/bin/sh

mysql -uroot -p12345 -e "CREATE DATABASE SYS_BENCH_TEST_DB"
sysbench --test=oltp --db-driver=mysql --oltp-table-size=100000 --mysql-user=root --mysql-password=12345 --mysql-db=SYS_BENCH_TEST_DB --num-threads=12 prepare
sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=SYS_BENCH_TEST_DB --mysql-user=root --mysql-password=12345 --max-time=60 --oltp-read-only=off --max-requests=0 --num-threads=8 run
sysbench --test=cpu  --cpu-max-prime=20000 run