# Continuous heritrix shell suite (CHSS)

- Developed and used for basic automation of continuous heritrix jobs from 2020/05, till 2022, with dedicated virtual machines / containers heritrix instances in Webarchive CZ.

# 1. Deployement and usage of CHSS
## 1.1.Prerequisities
	- Running on single VM/container and in single instance
  - Dedicated heritrix user
  - Accessible cron for dedicated user 
	- Installation of Java
  - Installation of [Heritrix vs. 3](https://github.com/internetarchive/heritrix3)
- necessary to set up with all system links / FS shares during deploy of crawling server and installation of heritrix engine are not part of this readme
- for more complex jobs, should be used DB templates, AMQP protocols and asynchronous event processing

## 1.2. Structure of dirs

- Continuous suite is composed of several scripts and specialised functions for passive monitoring and simple running of continuous crawls with high intensisty
- Consists of:
	- project directory - Specific continuous dir
		- stat-checks 	- Statistics samples logs dir
		- logs-runtime 	- Runtime logs dir
	- central directory - General dir for all projects
	- archival directory - <i>structure not included here</i>, dependent on each case and overall archival strategy, also as FS structure

## 1.3. Basic operation
- 1. pull and deploy
```console
cd <Crawler-config-dir>
git pull https://github.com/JanMeritus/continuous-suite
cd continuous-suite
mv project-dir <Project-dir>
```
- 2. create new cron record
```console
heritrix@crawler:~$ crontab -e
6    4,9,13,17,21    *    *    * <project_dir>/continuous-suite.sh >> <project_dir>/logs_runtime/<project_name>-cs-`date +\%Y\%m`.log 2>&1
```
- 3. before running, it is necessary to configure paths and variables (see lower, in 2. Customisations)

# 2. Customisations

## 2.1. Project directory of continuous crawl
- main project directory and settings for <i>each</i> continuous project
	- for each instance of continuous crawl create own directory
- necessary to set up project path: <Crawler-config-dir>/<Continuous-Project-dir>
- installation
	- by deploying project-dir for concrete continuous type project

```console
cd <Project-dir> 
ls
continuous-suite.sh   # Main running script, flow of events
settings-continuous.cfg.sh  # Main settings, sourcing
seeds.txt               # Actual seeds - could be customised, eg. tsv import
stat-checks             # Directory for aggregated crawl sample statistics in tsv format, eg. Continuous-Cov19-2023-02-01-Cov19.techlog.tsv 
runtime-logs            #Logs of cron runtime
```

### 2.1.1. File settings-continuous.cfg.sh
- main settings for crawler and crawl settings and continuous-suite
  - important - fill up with actual paths and dates
	- specification - typ - Key identifier composed from Type_ProjectName - expecting same as project directory
  - logins and passes set up in local .sh, not here
- settings categories
	- Crawler variables and paths
	- Crawl Metadata 
		- Dates (authomatic)
		- Project
      - important - typ - Key identifier composed from Type_ProjectName - expecting same as project directory
		- Paths
		- Organizational
	- Crawl Quantitative - Dynamic crawler values
	- Seeds source - TSV
	- Stats

### 2.1.2 File continuous-suite.sh
- main script with event flow and crawler set up and app logic
- uses other supporting scripts:
	- project dir
		- settings-continuous.cfg.sh
		- crawler-beans.template
	- central dir
		- start-crawler.sh
		- stat-checker.sh
	- archive dir
		- archive_logs.sh
- on first deploy: 
	- change target for sourcing settings-continuous.cfg.sh after project path: `source <Crawler-config-dir>/continuous-suite/<Project-dir>`
- structure:
	- 1. Initiation of variables
	- 2. Functions defintions
		- helping functions
	- 3. Seeds reactualization
		- reactualization of seedsm otpional
	- 4.A Crawl Initiation - Set up deploy
		- deploy crawler-beans.cxml after actual variables
	- 4.B Crawl Initiation - Crawler initiation
		- restart of heritrix crawler
	- 5. Crawl - Basic Event Flow 
	- 6. Archiving and operationa logs cleaning
- actual crawl flow accords to basic sequential crawl flow
	- Crawl Initiation
	- Crawl Launch
	- Crawl Unpausing - here depends at crawler setting
	- Crawl Runnning
	- Crawl Termination
	- Crawl Teardown

### 2.1.3 File crawler-beans.template
- supporting template file for crawl
- on deploy:
	- necessary credentials - either include own or comment it
		- for domain facebook.com
			- <actual-facebook-login>, <actual-facebook-pass>
		- for domain twitter.com
			- <actual-twitter-login>, <actual-twitter-pass>
		- etc. set up credentialStore
	- customize local beans (ad hoc)
		- rejectLocalCalendars.regexList
		- surtPrefixes
		- rejectLocalCalendars-sheet
		- rejectLocalTraps-sheet
		- SurtPrefixesSheetAssociation
- structure of main settings and their template (change only ad hoc project / project type / structure)
	- basic settings
		- metadata.jobName=%TYP% %DNES%-%SHORT_N%
		- metadata.operator=%ACTUAL_OPERATOR%
		- metadata.description=%M_COMMENT%
		- warcWriter.prefix=%TYP%-%DNES%-%SHORT_N%_%CRAWLER_HOST%-
		- warcWriter.storePaths=%CORE_STORE%/%TYP_LC%/%TYP%-%DNES%-%SHORT_N%
	- duplication reduction and ops
		- historyBdb.dir=%CRAWLER_JOBS%/history/%YEAR%-history-state-year
		- bdb.dir=%CRAWLER_JOBS%/states/%TYP_LC%/%YEAR%
		- crawlController.scratchDir=%CRAWLER_JOBS%/scratchx%TYP_LC%
	- settings
		- frontier.balanceReplenishAmount=%BALANCE_REPLENISHAM%
		- crawlController.maxToeThreads=%MAX_TOETHREADS% 
		- crawlLimiter.maxTimeSeconds=%MAX_TIMESECONDS%
		- #tooManyHopsDecideRule.maxHops=%MAX_HOPS%
		- #transclusionDecideRules.maxTransHops=%MAX_TRANSHOPS%
		- #transclusionDecideRules.maxSpeculativeHops=%MAX_SPECHOPS%
		- #scope.maxHops=%MAX_HOPS%
		- #scope.maxTransHops=%MAX_TRANSHOPS%
		- #scope.maxSpeculativeHops=%MAX_SPECHOPS%
		- warcWriter.poolMaxActive=%POOL_MAXACTIVE%
	- metadata
		- metadata.operatorContactUrl=%OPER_WEB%
		- metadata.operatorFrom=%OPER_MAIL%
		- metadata.organization=%OPER_ORGANIZATIONFULL%
		- metadata.audience=%OPER_AUDIENCE%
		- metadata.userAgentTemplate=%OPER_TEMPLATE%
	- storePaths
		- %CORE_STORE%/%TYP_LC%/%TYP%-%DNES%-%SHORT_N% 


## 2.2 Central opt directory
- contains scripts central to multipurpose use, not only
```console
/opt/heritrix
start-crawler.sh 		# Crawler starting script
stat-checker.sh 		# Statistics checking
```

### 2.2.1. File stat-checker.sh
- creates statistic logs ".techlog.tsv"
- usage: 
	- automatical from continuous-script.sh 
	- manual: `<central-dir-path>/crawlchecker.sh <runtime_seconds> Continuous-Cov19-YYYY-MM-DD-Cov19 <ip_adress> <port>`
- set up variables
  - type, ip-adress, file_name, runtime in seconds are taken from Main settings (settings.topics.cfg.sh  )
  ```
  runtime="${1} seconds"
  TYP=${2}		# "Continuous-X"
  ADDRESS=${4}	# "IP adress X.X.X.X"
  PORT=${5} 	# port
  FName=${3}	# Path+Filename
  ```
  - login and password need to set up locally
  ```
  login="<actual-login>"
  pass="<actual-password>"
  ```
### 2.2.2. File start-crawler.sh
- starts crawler with defined parametres
- on deploy:
  - change `<actual-crawler-login>`,`<actual-crawler-password>`
- usage:
  - automatical from continuous-script.sh
  - manual 
  ```console
  start-crawler.sh <crawler_ip> <port> <java-XmxInMB> <java-XmsInMB> <HERITRIX_HOME> <JAVA_HOME>
  ```

## 2.3. Archive dir
- recommended strutcture for logging /mnt/archives/rok/continuous-name
vcitane scriptu z toolboxu pre ukladanie logov

### 2.3.1. File archive_logs.sh
- external script, created by R. Kreibich and updated by P. Habetinova
- added for inspiration

# 3. Indexation and Publication
- missing from scope of this project
- it is dependent on indexation processess of project and archive needs

# 4. Logs structure

## 4.1. Runtime logs
- basic process related structure with datetime

## 4.2. Structure of statisctic logs .tsv
- samples by set up frequency, should cover main aspects of crawl runtime
```tsv
| date | elapsedMilliseconds | lastReachedState | novel | dupByHash | warcNovelContentBytes | warcNovelUrls | activeQueues | snoozedQueues | exhaustedQueues | busyThreads | congestionRatio | currentKiBPerSec | currentDocsPerSecond | usedBytes | alertCount |
 | ----- | ---------- | ---- | ---------- | ---------- | ---------- | ------ | ---- | ---- | ---- | ---- | --- | --- | ---- | --- | ------- | ---- |
| 09:09:32 |  33102  |  PAUSE  |  0  |  0  |   |   |  0  |  0  |  0  |  0  |   |  0  |  0  |  1293253128  |  0  | 
| 09:10:34 |  93431  |  RUN  |  60365985  |  88987568  |  60366378  |  1392  |  492  |  229  |  120  |  150  |  12.997361  |  2124  |  35  |  1463790776  |  0  | 
| 09:11:38 |  155843  |  RUN  |  169967391  |  286983358  |  169967914  |  2711  |  596  |  396  |  194  |  150  |  10.399267  |  5432  |  98  |  1384826816  |  0  | 
| 09:12:40 |  218913  |  RUN  |  318117678  |  623741404  |  318118201  |  4458  |  712  |  542  |  295  |  150  |  9.520231  |  7712  |  102  |  3413708416  |  0  |
```

## 4.3. Other logs
- accessible in archived crawl dirs, standardly created by heritrix

# 5. License

Continuous suite is free software; you can redistribute it and/or modify it under the terms of the GNU GPL 3, with reservation to secrets generally and path and date customisations in continuous-setting.cfg.sh.
