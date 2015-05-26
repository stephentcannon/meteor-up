#!/bin/bash

APPNAME=<%= appName %>
APP_PATH=/opt/$APPNAME
BUNDLE_PATH=$APP_PATH/current
ENV_FILE=$APP_PATH/config/env.list
PORT=<%= port %>
USE_LOCAL_MONGO=<%= useLocalMongo? "1" : "0" %>

# remove previous version of the app, if exists
docker rm -f $APPNAME

# remove frontend container if exists
docker rm -f $APPNAME-frontend

set -e
docker pull etherpos/meteord:forcessl

if [ "$USE_LOCAL_MONGO" == "1" ]; then
  docker run \
    -d \
    --restart=always \
    --publish=$PORT:$PORT \
    --volume=$BUNDLE_PATH:/bundle \
    --env-file=$ENV_FILE \
    --link=mongodb:mongodb \
    --hostname="$HOSTNAME-$APPNAME" \
    --env=MONGO_URL=mongodb://mongodb:27017/$APPNAME \
    --name=$APPNAME \
    etherpos/meteord:forcessl
else
  docker run \
    -d \
    --restart=always \
    --publish=$PORT:$PORT \
    --volume=$BUNDLE_PATH:/bundle \
    --hostname="$HOSTNAME-$APPNAME" \
    --env-file=$ENV_FILE \
    --name=$APPNAME \
    etherpos/meteord:forcessl
fi

<% if(typeof sslConfig === "object")  { %>
  docker pull etherpos/mup-frontend-server:forcessl
  docker run \
    -d \
    --restart=always \
    --volume=/opt/$APPNAME/config/bundle.crt:/bundle.crt \
    --volume=/opt/$APPNAME/config/private.key:/private.key \
    --link=$APPNAME:backend \
    --publish=80:80 \
    --publish=<%= sslConfig.port %>:443 \
    --name=$APPNAME-frontend \
    etherpos/mup-frontend-server:forcessl /start.sh
<% } %>