#!/bin/bash
# vs. 0.1 Zdenko Vozar, 2020 05 01, input DURATION, TYPE, SKLIZEN,  ADDRESS
# vs. 0.2 Zdenko Vozar, 2023 05 08, FREQUENCY, PORT
# use: <central-dir-path>/crawlchecker.sh <runtime_seconds> <frequency >Continuous-Cov19-YYYY-MM-DD-Cov19 <ip_adress> <port>

login="<actual-heritrix-login>"
pass="<actual-heritrix-password>"

TYP=${3} 		# "Continuous-Cov19-YYYY-MM-DD-Cov19"
ADDRESS=${5} 	# "IP adress X.X.X.X"
PORT=${6}		# eg XXXX
FName=${4}.     # Path+Filename

FREQUENCY=${2}    	# frequency of logging
runtime="${1} seconds"
endtime=$(date -ud "$runtime" +%s)

# Initial format

#`date +%H:%M:%S`" ${elapsedMilliseconds} ${lastReachedState} ${novel} ${dupByHash} ${warcNovelContentBytes} ${warcNovelUrls} ${activeQueues} ${snoozedQueues} ${exhaustedQueues} ${busyThreads} ${congestionRatio} ${currentKiBPerSec} ${currentDocsPerSecond} ${usedBytes} ${alertCount}

echo "| date | elapsedMilliseconds | lastReachedState | novel | dupByHash | warcNovelContentBytes | warcNovelUrls | activeQueues | snoozedQueues | exhaustedQueues | busyThreads | congestionRatio | currentKiBPerSec | currentDocsPerSecond | usedBytes | alertCount |" >> ${FName}.techlog.tsv

echo " | ----- | ---------- | ---- | ---------- | ---------- | ---------- | ------ | ---- | ---- | ---- | ---- | --- | --- | ---- | --- | ------- | ---- |" >> ${FName}.techlog.tsv

# Check status

while [[ $(date -u +%s) -le $endtime ]]
do

        x=$(curl -s -k -u ${login}:${pass} --anyauth --location -H "Accept: application/xml" https://${ADDRESS}:${PORT}/engine/job/${TYP})

        #echo ${x}
        #xmllint --xpath 'string(/novel)' ${x} #new OS

        novel=$(echo ${x} | grep -Po '<novel>\K\d+')
        novelCount=$(echo ${x} | grep -Po '<novelCount>\K\d+' | awk '{$1/=1024*1024;printf "%.2f\n",$1}')
        dupByHash=$(echo ${x} | grep -Po '<dupByHash>\K\d+')
        dupByHashCount=$(echo ${x} | grep -Po '<dupByHashCount>\K\d+')
        warcNovelContentBytes=$(echo ${x} | grep -Po '<warcNovelContentBytes>\K\d+')
        warcNovelUrls=$(echo ${x} | grep -Po '<warcNovelUrls>\K\d+')
        currentKiBPerSec=$(echo ${x} | grep -Po '<currentKiBPerSec>\K\d+')
        averageKiBPerSec=$(echo ${x} | grep -Po '<averageKiBPerSec>\K\d+(?:\.\d+)?')
        currentDocsPerSecond=$(echo ${x} | grep -Po '<currentDocsPerSecond>\K\d+')
        averageDocsPerSecond=$(echo ${x} | grep -Po '<averageDocsPerSecond>\K\d+')
        congestionRatio=$(echo ${x} | grep -Po '<congestionRatio>\K\d+(?:\.\d+)?')
        busyThreads=$(echo ${x} | grep -Po '<busyThreads>\K\d+')
        totalThreads=$(echo ${x} | grep -Po '<totalThreads>\K\d+')
        averageQueueDepth=$(echo ${x} | grep -Po '<averageQueueDepth>\K\d+')
        deepestQueueDepth=$(echo ${x} | grep -Po '<deepestQueueDepth>\K\d+')
        elapsedMilliseconds=$(echo ${x} | grep -Po '<elapsedMilliseconds>\K\d+')
        totalQueues=$(echo ${x} | grep -Po '<totalQueues>\K\d+')
        exhaustedQueues=$(echo ${x} | grep -Po '<exhaustedQueues>\K\d+')
        activeQueues=$(echo ${x} | grep -Po '<activeQueues>\K\d+')
        snoozedQueues=$(echo ${x} | grep -Po '<snoozedQueues>\K\d+')
        lastReachedState=$(echo ${x} | grep -Po '<lastReachedState>\K\w+')
        usedBytes=$(echo ${x} | grep -Po '<usedBytes>\K\d+')
        alertCount=$(echo ${x} | grep -Po '<alertCount>\K\d+')

        echo "| `date +%H:%M:%S` | " ${elapsedMilliseconds} " | " ${lastReachedState} " | " ${novel} " | " ${dupByHash} " | " ${warcNovelContentBytes} " | " ${warcNovelUrls} " | " ${activeQueues} " | " ${snoozedQueues} " | " ${exhaustedQueues} " | " ${busyThreads} " | " ${congestionRatio} " | " ${currentKiBPerSec} " | " ${currentDocsPerSecond} " | " ${usedBytes} " | " ${alertCount} " | " >> ${FName}.techlog.tsv
        sleep ${FREQUENCY} #s
done
