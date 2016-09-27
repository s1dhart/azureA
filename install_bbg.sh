#!/bin/bash
wget https://support.olmsystems.com/olm/application_store/downloads/BBG/V1_0.tar.gz 
sudo apt-get update
tar xvzf V1_0.tar.gz 
sudo dpkg --install --force-all nginx-common.deb nginx-full.deb webmin.deb
sudo apt-get install -f 
sudo /usr/share/webmin/install-module.pl webmin_nginx.gz
sudo service nginx stop 
sudo tar Pxvzf nginx-conf.tar.gz
sudo openssl dhparam -out /etc/nginx/ssl/dhparams.pem 2048 
sudo service nginx start 
sudo cp /etc/nginx/sites-available/_eclipse_template /etc/nginx/sites-available/perf
cd /etc/nginx/sites-available
sudo sed -i s/192.168.1.10/10.0.2.20/g perf
sudo sed -i s/ENV.fq.dn/perftest.westeurope.cloudapp.azure.com/g perf
sudo sed -i s/ENV/perf/g perf
cd /etc/nginx/sites-enabled
sudo ln -s /etc/nginx/sites-available/perf perf
sudo service nginx reload
