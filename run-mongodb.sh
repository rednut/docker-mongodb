#!/usr/bin/env bash


IMAGE=rednut/mongodb
CONTAINERNAME=mongo
REPLICA_SET_NAME="rednut-dev"
LOCAL_PUBLIC_IP=10.9.1.9

docker stop $CONTAINERNAME || echo "container $CONTAINERNAME not runnning"
docker rm $CONTAINERNAME || echo "container $CONTAINERNAME not a container yet"


docker run -d \
	-p $LOCAL_PUBLIC_IP:27017:27017 \
	-p $LOCAL_PUBLIC_IP:28017:28017 \
	-v /docker/mongodb/db:/data/db \
	--name=$CONTAINERNAME \
	$IMAGE \
		mongod --rest --httpinterface --smallfiles 
#--replSet "$REPLICA_SET_NAME"
