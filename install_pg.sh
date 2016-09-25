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
sudo ln -s /opt/postgresql-9.3.5 /opt/pgsql
sudo mkdir -p /opt/pgsql_data
sudo useradd -m postgres
sudo chown -R postgres.postgres /opt/pgsql_data
##
# Set Environments
##
sudo touch /home/postgres/.bash_profile
sudo chown postgres.postgres /home/postgres/.bash_profile
cat >> /tmp/postgres.sh <<EOF
cat >> /home/postgres/.bash_profile <<EOFF
export PGHOME=/opt/PostgreSQL
export PATH=\\\$PATH:\\\$PGHOME/bin
export MANPATH=\\\$MANPATH:\\\$PGHOME/share/man
export DATA=\`date +"%Y%m%d%H%M"\`
export PGUSER=postgres
alias rm='rm -i'
alias ll='ls -lh'
EOFF
source /home/postgres/.bash_profile
# Install PG
./postgresql-9.5.4-1-linux-x64.run --mode unattended --prefix /opt/PostgreSQL/9.5 --datadir /opt/PostgreSQL/9.5/data --superpassword password --serverport 5432 --locale en_GB.utf8
# Create DB
sudo su - postgres -c "createdb -h localhost -p 5432 -U postgres ecl_test"
