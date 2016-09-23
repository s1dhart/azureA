#!/bin/bash
wget http://support.olmsystems.com/olm/application_store/admin/downloads/Eclipse/eclipse-installer-1.3.0-RELEASE.jar.gz
wget http://support.olmsystems.com/olm/application_store/admin/downloads/Eclipse/server-jre-8u101-linux-x64.tar.gz
mv eclipse-installer-1.3.0-RELEASE.jar.gz eclipse-installer-1.3.0-RELEASE.jar
tar xzf server-jre-8u101-linux-x64.tar.gz
jdk1.8.0_101/bin/java \
-DTRACE=true \
-DDEBUG=true \
-Dinput.target.db.server.hostname=10.0.2.40 \
-Dinput.target.db.server.dbname_schema=ecl_test \
-Dinput.target.db.server.port=5432 \
-Dinput.target.tomcat.http.port=8080 \
-Dinput.target.ajp.port=8009 \
-Dinput.target.install.environment=test \
-Dinput.target.db.username=ecl_test \
-Dinput.target.db.password=ecl_test \
-Dinput.target.db.platform=POSTGRESQL \
-Dinput.target.install.user=testusp \
-Dinput.target.install.group=uspgroup \
-jar eclipse-installer-1.3.0-RELEASE.jar \
-console \
-options-system
start olm_test_eclipse
