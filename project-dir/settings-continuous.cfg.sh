#!/bin/bash

# Crawler variables and paths
ADDRESS='<ip-address>'
PORT='<port>' # 7778
HERITRIX_HOME='<heritrix_home>' #/opt/heritrix/running
JAVA_HOME='<java_home>'			#/opt/java/testing
JAVAO_XMX='12000'
JAVAO_XMS='256'
CRAWLER_HOST='<crawler_host_name>'
CRAWLER_JOBS='<crawler_jobs_path>'
CRAWLER_CENT_DIR='<crawler_central_opt_path>' #/opt/heritrix
CRAWLER_CENT_DIR='/Users/zdenkovozar/GIT/continuous-suite/central-dir'

#Crawl Metadata - Dates
TODAY_DATE=$(date +'%Y-%m-%d')
YEAR=$(date +'%y')

# Crawl Metadata - Project
TYP='<Continuous-ProjectName>'    #Key project name
TYP_LC=$(echo "$TYP" | tr '[:upper:]' '[:lower:]')
TYPPATH="${CRAWLER_JOBS}/Crawler-config/${TYP}"
TYPPATH='/Users/zdenkovozar/GIT/continuous-suite/project-dir'
NAME_SHORT="<SpecialName>${YEAR}"
M_COMMENT='<Commentary about crawl topic>'

#Crawl Metadata - Paths
CORE_STORE="<mnt_store_path/>${YEAR}"
CORE_STORE="<mnt_store_path/>${YEAR}" #alternative path commented in template

# Crawl Metadata - Organizational

ACTUAL_OPERATOR='<name-surname>'
OPER_WEB='<url>'
OPER_MAIL='<mail>'
OPER_ORGANIZATIONFULL='<organization-name-full>'
OPER_AUDIENCE='<audience strings>'
#OPER_AGENTTEMPLATE='Mozilla/5.0 (compatible; heritrix'

# Seeds source - TSV
SEEDS_ADDRESS='<seeds-url><optional-google_docs/pub?gid=ID&single=true&output=tsv'

# Stats
FREQUENCY=60 #in seconds for statistics sampling

# Crawl Quantitative - Dynamic crawler values
BUDGET=5000
BALANCE_REPLENISHAM=300
MAX_TOETHREADS=150
MAX_TIMESECONDS=7200
MAX_HOPS=3
MAX_TRANSHOPS=1
MAX_SPECHOPS=1
POOL_MAXACTIVE=2


