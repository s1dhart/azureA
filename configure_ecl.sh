#!/bin/bash
sudo apt-get update 
#install the necessary tools 
sudo apt-get install openjdk-7-jre
#download postgresql source code
wget https://support.olmsystems.com/olm/application_store/admin/downloads/Eclipse/eclipse-installer-1.3.0-RELEASE.jar.gz
sudo java \
-DTRACE=true \
-DDEBUG=true \
-Dinput.target.db.server.hostname=10.0.2.40 \
-Dinput.target.db.server.dbname_schema=live \
-Dinput.target.db.server.port=1999 \
-Dinput.target.install.environment=live \
-Dinput.target.db.username=postgres \
-Dinput.target.db.password=postgres \
-Dinput.target.db.platform=POSTGRESQL \
-Dinput.target.install.user=autouser \
-Dinput.target.install.group=autogroup \
-jar /home/sid/eclipse-installer-1.3.0-SNAPSHOT.jargz \
-console \
-options-system
sudo start olm_live_eclipse
#install postgresql
