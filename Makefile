name  := sctu.net
build := $(shell git describe --tags --always)

.PHONY: all apply clean shell

all: www.sha256sum

.docker:
	mkdir -p $@

.docker/%: | .docker
	docker build \
	--build-arg AWS_ACCESS_KEY_ID \
	--build-arg AWS_DEFAULT_REGION \
	--build-arg AWS_SECRET_ACCESS_KEY \
	--build-arg TF_VAR_release=$* \
	--iidfile $@ \
	--tag sctu/$(name):$* .

apply: .docker/$(build)
	docker run --rm \
	--env AWS_ACCESS_KEY_ID \
	--env AWS_DEFAULT_REGION \
	--env AWS_SECRET_ACCESS_KEY \
	$(shell cat $<)

clean:
	-docker image rm -f $(shell sed G .docker/*)
	-rm -rf .docker www.sha256sum

www.sha256sum: .docker/$(build)
	docker run --rm $(shell cat $<) cat /var/task/$@ > $@

shell: .docker/$(build) .env
	docker run --rm -it --env-file .env $(shell cat $<) /bin/bash
