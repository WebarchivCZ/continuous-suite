# !/bin/bash
# vs.0.1 by Rudolf Kreibich
# vs.0.2 recent changes by Petra Habětínová
# usage ./archive_logs.sh /mnt/archives/heritrix_jobs_dir
# Script which grep crawler-beans.cxml for warcWriter.storePath to get path to which archive logs.
# it creates *.warc.gz/logs/crawl hiearchy

# binary for indexer tool
# relative paths should align in working directory
cd $1

for DIR in $(find . -type d -name '[[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]]'); do # Using globular expression for 14 char long timestamp because I am lazyto use regex;-)
  WARC_DIR=$(grep warcWriter\.store $DIR/crawler-beans.cxml | sed -r 's/^.*=//' | tr -d '\r' )
  JOB_NAME=$(grep warcWriter\.prefix $DIR/crawler-beans.cxml | sed -r 's/^.*=//'| tr -d '\r' )
  JOB_DIR=$(basename $DIR)

echo argument for working dir: $1
echo Warc dir: ${WARC_DIR}
echo Job dir: ${JOB_DIR}
echo Job name: ${JOB_NAME}

#read -rsp $'Press any key to continue...\n' -n 1 key


# We need proper directory structure
#if [ -d $WARC_DIR ]; then # WARC dir should exists
#   if [ -d $WARC_DIR/logs ]; then # logs dir too
#      if [ ! -d $WARC_DIR/logs/crawl ]; then # logs/crawl should exists
#       mkdir $WARC_DIR/logs/crawl
#      fi
#fi
#   else
      mkdir -p $WARC_DIR/logs/crawl # We want dir to exists
#fi

#read -rsp $'Press any key to continue...\n' -n 1 key                                                                                                                                   


if [ -d $WARC_DIR/logs/crawl ] && [ -w $WARC_DIR/logs/crawl ] && [ ! -a $WARC_DIR/logs/crawl/$JOB_NAME-$JOB_DIR-$(hostname).tar.gz ]; then # If dest file does not exists and path is writable, we tar;-)

	tar czvf $WARC_DIR/logs/crawl/$JOB_NAME-$JOB_DIR-$(hostname)-logs.tar.gz $JOB_DIR && rm -rf $JOB_DIR
fi
done
