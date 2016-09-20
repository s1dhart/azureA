#!/bin/bash
Sudo apt-get install openjdk-7-jre
touch /tmp/a
cd /home/sid
sudo java \
-DTRACE=true \
-DDEBUG=true \
-Dinput.target.db.server.hostname=EclDB \
-Dinput.target.db.server.dbname_schema=live \
-Dinput.target.db.server.port=1999 \
-Dinput.target.install.environment=live \
-Dinput.target.db.username=postgres \
-Dinput.target.db.password=postgres \
-Dinput.target.db.platform=POSTGRESQL \
-Dinput.target.install.user=autouser \
-Dinput.target.install.group=autogroup \
-jar /home/sid/eclipse-installer-1.3.0-SNAPSHOT.jar \
-console \
-options-system
sudo start olm_live_eclipse
