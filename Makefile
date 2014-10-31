USER = rednut
NAME = mongo
REPO = $(USER)/$(NAME)
VERSION = $(shell touch VERSION && cat VERSION)

CONTAINER = mongo

LOCAL_IP = 10.9.1.9
PORT_DB = $(LOCAL_IP):27017:27017
PORT_HTTP = $(LOCAL_IP):28017:28017

LDATA_VOL = /docker/mongodb/db
CDATA_VOL = /data/db
PDATA_VOL = $(LDATA_VOL):$(CDATA_VOL)


RUN_OPTS = -p $(PORT_DB) -p $(PORT_HTTP) -v $(PDATA_VOL)
CMD = mongod
CMD_ARGS = --smallfiles 


build: version_inc build_image tag_latest


version_inc:
	@VERSION inc

tag_latest:
	@docker tag $(REPO):$(VERSION) $(REPO):latest


build_image:
	@docker build -t="$(REPO):$(VERSION)" --rm .

stop: stopc

stopc:
	docker stop $(CONTAINER) || echo "cannot stop container '$(CONTAINER)' as it is not currently runing?"

rmc: stopc
	docker rm $(CONTAINER) || echo "cannot remove container '$(CONTAINER)'"

cleanrunningcontainer: stopc rmc

run: cleanrunningcontainer runhttp


runnohttp: cleanrunningcontainer
	docker run -d --name=$(CONTAINER) -p $(PORT_DB) -v $(PDATA_VOL) $(REPO) $(CMD) $(CMD_ARGS)

runhttp: cleanrunningcontainer
	docker run -d $(RUN_OPTS) --name=$(CONTAINER) $(REPO) $(CMD) --rest --httpinterface $(CMD_ARGS)

client:
	docker run -it --rm --link $(CONTAINER):$(CONTAINER) $(REPO) bash -c 'ping -c 3 $(CONTAINER) ; mongo --host $(CONTAINER)'


