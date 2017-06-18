ECHO_API=localhost:9191
DUMMY_API=localhost:9192
ECHO_CONTAINER=gohealthcheck_echo_1
DUMMY_CONTAINER=gohealthcheck_dummy_1
HEALTH_CONTAINER=gohealthcheck_health_1

DOCKER_ID=`docker ps -a -f name={DUMMY_CONTAINER} --format "{{.ID}}"`
DUMMY_RESULT=`curl -s -o /dev/null ${DUMMY_API} -w  '{"http_code" : "%{http_code}"}' | jq -r '.http_code'`
ECHO_RESULT=`curl -s -o /dev/null ${ECHO_API} -w  '{"http_code" : "%{http_code}"}' | jq -r '.http_code'`

echo1:
	#http localhost:9191 msg=='something msg' code==123
	echo ${ECHO_RESULT}

dummy1:
	#http localhost:9192
	echo ${DUMMY_RESULT}

echoin:
	docker exec -it ${ECHO_CONTAINER} bash

healthin:
	docker exec -it ${HEALTH_CONTAINER} bash

curl:
    #After docker is executed, it doesn't work.
    curl -s --unix-socket /var/run/docker.sock http:/v1.30/containers/json?all=1&filters=%7b%22name%22%3a%20%5b%22gohealthcheck_dummy_1%22%5d%7d | jq -r '.[0] | .Id'
    curl -s --unix-socket /var/run/docker.sock http:/v1.30/containers/json?all=1&filters={%22status%22:[%22exited%22]} | jq -r '.[0] | .Id'

    curl -s --unix-socket /var/run/docker.sock http:/v1.30/containers/json?all=1 | jq -cr '.[] | select(.Image=="go-healthcheck-dummy:1.0") | .Id'

jq -c '.[].group1.subg01[] | select(.id == "1021")'
log:
	docker inspect ${DOCKER_ID}
	docker inspect ${DOCKER_ID} -f '{{index .State.Health.Log 0}}'
	docker inspect ${DOCKER_ID} -f '{{index .State.Health.Log 1}}'
