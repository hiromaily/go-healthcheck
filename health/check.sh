#!/bin/bash

echo "[HealthCheck] Run healthcheck"

DOCKER_API_VER=v1.30
DUMMY_API=http://dummy-server/
ECHO_API=http://echo-server
#ECHO_API=localhost:9191/
CONTAINER_NAME=gohealthcheck_dummy_1


# call health check API
RESULT=`curl -s -o /dev/null "${DUMMY_API}" -w  '{"http_code" : "%{http_code}"}' | jq -r '.http_code'`
if echo $RESULT | grep -q 200; then
	echo '[HealthCheck] It works!'
	#http ${ECHO_API} msg=='OK' code==200
	curl -G -d "msg=OK&code=200" ${ECHO_API}
else
	echo '[HealthCheck] Not working'
	curl -G -d "msg=NG&code=500" ${ECHO_API}

	# Check ID of server container
	# Note: exited state container can not be retrieved without all=1
	#SERVER_PID=$(curl -s --unix-socket /var/run/docker.sock http:/${DOCKER_API_VER}/containers/json?filters=%7b%22name%22%3a%20%5b%22${CONTAINER_NAME}%22%5d%7d | jq -r '.[0] | .Id')
	SERVER_PID=$(curl -s --unix-socket /var/run/docker.sock http:/${DOCKER_API_VER}/containers/json?all=1 | jq -cr '.[] | select(.Image=="go-healthcheck-dummy:1.0") | .Id')

	EXIT_STATUS=$?
	if [ $EXIT_STATUS -gt 0 ]; then
		#http ${ECHO_API} msg=='docker container id can not be gotten' code==500
		curl -G -d "msg=docker%20container%20id%20can%20not%20be%20gotten&code=500" ${ECHO_API}
		exit 0
	fi

	# Check server status whether restart is ongoing or not
	#SERVER_STATE=$(curl -s --unix-socket /var/run/docker.sock http:/${DOCKER_API_VER}/containers/json?filters=%7b%22name%22%3a%20%5b%22${CONTAINER_NAME}%22%5d%7d | jq -r '.[0] | .State')
	SERVER_STATE=$(curl -s --unix-socket /var/run/docker.sock http:/${DOCKER_API_VER}/containers/json?all=1 | jq -cr '.[] | select(.Image=="go-healthcheck-dummy:1.0") | .State')

	EXIT_STATUS=$?
	if [ $EXIT_STATUS -gt 0 ]; then
		#http ${ECHO_API} msg=='docker container state can not be gotten' code==500
		curl -G -d "msg=docker%20container%20state%20can%20not%20be%20gotten&code=500" ${ECHO_API}
		exit 0
	fi

	#SERVER_STATE may be `running` or `restarting` or `exited` or `dead` or `paused`
	#http http ${ECHO_API} msg=='docker container state is ${SERVER_STATE}' code==000
	curl -G -d "msg=docker%20container%20state%20is%20${SERVER_STATE}&code=000" ${ECHO_API}
	if echo $SERVER_STATE | grep -q exited; then
		# Restart
		curl --unix-socket /var/run/docker.sock -X POST http:/${DOCKER_API_VER}/containers/${SERVER_PID}/restart
	fi
fi
