#!/bin/bash

ROOT_DIR=/opt/cronicle
CONF_DIR=$ROOT_DIR/conf
BIN_DIR=$ROOT_DIR/bin
LIB_DIR=$ROOT_DIR/lib
# DATA_DIR needs to be the same as the exposed Docker volume in Dockerfile
DATA_DIR=$ROOT_DIR/data
# PLUGINS_DIR needs to be the same as the exposed Docker volume in Dockerfile
PLUGINS_DIR=$ROOT_DIR/plugins

# The env variables below are needed for Docker and cannot be overwritten
export CRONICLE_Storage__Filesystem__base_dir=${DATA_DIR}
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
export CRONICLE_echo=1
export CRONICLE_foreground=1


# Only run setup when setup needs to be done
if [ ! -f $DATA_DIR/.setup_done ]
then
  cp $CONF_DIR/setup.json $CONF_DIR/setup.json.origin
  cp $CONF_DIR/config.json $CONF_DIR/config.json.origin
  cp /cronicle/setup.json $CONF_DIR/setup.json

  $BIN_DIR/control.sh setup


  if [ -f $DATA_DIR/config.json.import ]
  then
    # Move in custom configuration
    cp $DATA_DIR/config.json.import $CONF_DIR/config.json
  fi

  # Create plugins directory
  mkdir -p $PLUGINS_DIR
  cp -v /cronicle/plugins/*.sh  $PLUGINS_DIR

  chmod -R 0755 $PLUGINS_DIR/*.sh

  # run job creation script
  $PLUGINS_DIR/create-jobs.sh . &

  # Marking setup done
  touch $DATA_DIR/.setup_done
fi


# Run cronicle
/usr/local/bin/node "$LIB_DIR/main.js"




