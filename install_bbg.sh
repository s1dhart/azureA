#!/bin/bash
wget https://support.olmsystems.com/olm/application_store/downloads/BBG/V1_0.tar.gz 
tar xvzf V1_0.tar.gz 
sudo dpkg --install nginx-common.deb nginx-full.deb webmin.deb 
sudo apt-get install -f 
sudo /usr/share/webmin/install-module.pl webmin_nginx.gz 
sudo service nginx stop 
sudo tar Pxvzf nginx-conf.tar.gz 
sudo openssl dhparam -out /etc/nginx/ssl/dhparams.pem 2048 
sudo ./bbgadmin.sh testpass 
sudo service nginx start 
