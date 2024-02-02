#!/bin/sh
# usage: start-crawler.sh <crawler_ip> <port> <java-XmxInMB> <java-XmsInMB> <HERITRIX_HOME> <JAVA_HOME>

heritrix_user="<actual-crawler-login>"
heritrix_password="<actual-crawler-password>"
heritrix_bind=${1}
heritrix_port=${2}
javao_Xmx=${3}
javao_Xms=${4}

export HERITRIX_HOME=${5}
export JAVA_HOME=${6}
export JAVA_OPTS="-server -Xmx$javao_Xmx -Xms$javao_Xms -XX:+UseParallelGC"  
#export JAVA_OPTS="-server -Xmx12000M -Xms256M -XX:+UseParallelGC -Dcom.sun.management.jmxremote.port=5000 -Djava.rmi.server.hostname=${heritrix_bind} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
$HERITRIX_HOME/bin/heritrix -a $heritrix_user:$heritrix_password -b $heritrix_bind -p $heritrix_port
