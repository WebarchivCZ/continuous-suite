#!/bin/bash
# vs. 0.1 Zdenko Vozar, 2020 04 11 
# vs. 0.2 Zdenko Vozar, 2020 04 25 Moving vs template reorganisation. Dynamic values added
# vs. 0.25 Zdenko Vozar, 2022 02 26 adding engine initialization, cleaning and shutdown 
# vs. 0.3 Zdenko Vozar, 2023 05 08 script systemization
#usage: eg crontab #30    17    *    *    * /opt/heritrix/jobs/Crawler-config/Topics/sklizen-cov-script.sh >> /opt/heritrix/jobs/Crawler-config/Topics/covid.log 2>&1

# 1. Initiation of variables

#source <Crawler-config-dir>/<Project-dir>/settings-continuous.cfg.sh
source /Users/zdenkovozar/GIT/continuous-suite/project-dir/settings-continuous.cfg.sh
heritrix_user="<actual-crawler-login>"
heritrix_password="<actual-crawler-password>"

# 2. Functions

datetimenow_process () {
   dt=$(date '+%d/%m/%Y_%H:%M:%S');
   echo "${dt}:: ${1}"
}

# 3. Seeds reactualization
##wget --no-check-certificate -q -O - ${SEEDS_ADDRESS} | cut -f2 > ${TYPPATH}/prietok.log
##cat updatedblog.cz.csv | cut -f1 > ${TYPPATH}/prietok.log
##sed -e "s/\r//g" ${TYPPATH}/prietok.log | sort -u > ${TYPPATH}/seeds/${TYP}_${TODAY_DATE}_${NAME_SHORT}.txt

# 4.A Crawl Initiation - Set up deploy
##cp ${TYPPATH}/seeds/${TYP}_${TODAY_DATE}_${NAME_SHORT}.txt ${TYPPATH}/seeds.txt
echo ${OPER_AGENTTEMPLATE}
echo ${NAME_SHORT}
sed -e "s;%TODAY_DATE%;${TODAY_DATE};g" -e "s;%BUDGET%;${BUDGET};g" -e "s;%TYP%;${TYP};g" -e "s;%TYP_LC%;${TYP_LC};g" -e "s;%CRAWLER_HOST%;${CRAWLER_HOST};g" -e "s;%CRAWLER_JOBS%;${CRAWLER_JOBS};g" -e "s;%CORE_STORE%;${CORE_STORE};g" -e "s;%YEAR%;${YEAR};g" -e "s;%ACTUAL_OPERATOR%;${ACTUAL_OPERATOR};g" -e "s;%OPER_WEB%;${OPER_WEB};g" -e "s;%OPER_MAIL%;${OPER_MAIL};g" -e "s;%OPER_ORGANIZATIONFULL%;${OPER_ORGANIZATIONFULL};g" -e "s;%OPER_AUDIENCE%;${OPER_AUDIENCE};g" -e "s;%SHORT_N%;${NAME_SHORT};g" -e "s;%M_COMMENT%;${M_COMMENT};g" -e "s;%BALANCE_REPLENISHAM%;${BALANCE_REPLENISHAM};g" -e "s;%MAX_TOETHREADS%;${MAX_TOETHREADS};g" -e "s;%MAX_TIMESECONDS%;${MAX_TIMESECONDS};g" -e "s;%MAX_HOPS%;${MAX_HOPS};g" -e "s;%MAX_TRANSHOPS%;${MAX_TRANSHOPS};g" -e "s;%MAX_SPECHOPS%;${MAX_SPECHOPS};g" -e "s;%POOL_MAXACTIVE%;${POOL_MAXACTIVE};g"  ${TYPPATH}/crawler-beans.template > ${TYPPATH}/crawler-beans.cxml    #$1, -e ...$2 - bud parametre, alebo interne var
#todo git
#todo submit cxml via REST API to crawler + seeds

# 4.B Crawl Initiation - Crawler Initiation
pkill -u heritrix java
sleep 10
rm -rf ${CRAWLER_JOBS}/scratchx${TYP_LC}
${CRAWLER_CENT_DIR}/start-crawler.sh ${ADDRESS} ${PORT} ${JAVAO_XMX} ${JAVAO_XMS} ${HERITRIX_HOME} ${JAVA_HOME}
sleep 30

# 5. Crawl - Basic Event Flow 
datetimenow_process "Crawl Initiation"
curl -v -d "action=build" -k -u ${heritrix_user}:${heritrix_password} --anyauth --location -H "Accept: application/xml" https://${ADDRESS}:${PORT}/engine/job/${TYP}
sleep 60
datetimenow_process "Crawl Launch"
curl -v -d "action=launch" -k -u ${heritrix_user}:${heritrix_password} --anyauth --location -H "Accept: application/xml" https://${ADDRESS}:${PORT}/engine/job/${TYP}
sleep 60
datetimenow_process "Crawl Unpausing"
curl -v -d "action=unpause" -k -u ${heritrix_user}:${heritrix_password} --anyauth --location -H "Accept: application/xml" https://${ADDRESS}:${PORT}/engine/job/${TYP}
datetimenow_process "Crawl Runnning"
${CRAWLER_CENT_DIR}/stat-checker.sh ${MAX_TIMESECONDS} ${FREQUENCY} ${TYP} ${TYPPATH}/stat-checks/${TYP}-${TODAY_DATE}-${NAME_SHORT} ${ADDRESS} ${PORT}
sleep ${MAX_TIMESECONDS}
datetimenow_process "Crawl Termination"
${CRAWLER_CENT_DIR}/stat-checker.sh 900 ${FREQUENCY} ${TYP} ${TYPPATH}/stat-checks/${TYP}-${TODAY_DATE}-${NAME_SHORT} ${ADDRESS} ${PORT}
#sleep 3000
#curl -v -d "action=terminate" -k -u admin:travian --anyauth --location -H "Accept: application/xml" https://${ADDRESS}:7778/engine/job/${TYP}
sleep 900
datetimenow_process "Crawl Teardown"
curl -v -d "action=teardown" -k -u ${heritrix_user}:${heritrix_password} --anyauth --location -H "Accept: application/xml" https://${ADDRESS}:${PORT}/engine/job/${TYP}
datetimenow_process "Ukoncene"

sleep 60
pkill -u heritrix java
rm -rf ${CRAWLER_JOBS}/scratchx${TYP_LC}

# 6. Archiving and operationa logs cleaning
cd ${CORE_STORE}
./toolbox/archive_logs.sh ${TYPPATH}
datetimenow_process "Logy Zarchivovane"
