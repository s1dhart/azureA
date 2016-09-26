#!/bin/bash

wget http://get.enterprisedb.com/postgresql/postgresql-9.5.4-1-linux-x64.run
chmod 755 postgresql-9.5.4-1-linux-x64.run
##
# Ensure GB local is installed on OS
##
sudo locale-gen en_GB.utf8
##
#create postgres user for postgresql
##
sudo mkdir -p /opt/pgsql_data
sudo mkdir -p /opt/PostgreSQL
sudo useradd -m postgres
sudo chown -R postgres.postgres /opt/pgsql_data
sudo chown -R postgres.postgres /opt/PostgreSQL
##
# Set Environments
##
sudo touch /home/postgres/.bash_profile
sudo chown postgres.postgres /home/postgres/.bash_profile
cat >> /home/postgres/.bash_profile <<EOFF
export PGHOME=/opt/PostgreSQL/9.5
export PATH=\$PATH:\$PGHOME/bin
export MANPATH=\$MANPATH:\$PGHOME/share/man
EOFF
# Install PG
./postgresql-9.5.4-1-linux-x64.run --mode unattended --prefix /opt/PostgreSQL/9.5 --datadir /opt/PostgreSQL/9.5/data --superpassword password --serverport 5432 --locale en_GB.utf8
# Create DB
sudo su - postgres -c "createdb -h localhost -p 5432 -U postgres ecl_test"
sudo su - postgres -c "echo \"CREATE USER ecl_test WITH PASSWORD 'ecl_test';\" | PGPASSWORD=password psql -U postgres"
sudo printf "\nhost    all             all             10.0.2.40/24            trust\n" >> /opt/PostgreSQL/9.5/pg_hba.conf
sudo service postgresql-9.5 restart
