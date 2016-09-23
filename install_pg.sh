#!/bin/bash

wget http://get.enterprisedb.com/postgresql/postgresql-9.5.4-1-linux-x64.run
chmod 755 postgresql-9.5.4-1-linux-x64.run
sudo locale-gen en_GB.utf8
./postgresql-9.5.4-1-linux-x64.run --mode unattended --prefix /opt/PostgreSQL/9.5 --datadir /opt/PostgreSQL/9.5/data --superpassword password --serverport 5432 --locale en_GB.utf8
sudo su - postgres -c "createdb -h localhost -p 5432 -U postgres ecl_test"
