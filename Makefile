name   := sctu.net
stages := build test plan
build  := $(shell git describe --tags --always)
shells := $(foreach stage,$(stages),shell@$(stage))

terraform_version := 0.12.6

.PHONY: all apply clean up $(stages) $(shells)

all: www.sha256sum

.docker:
	mkdir -p $@

.docker/$(build)@plan: .docker/$(build)@build
.docker/$(build)@%: | .docker
	docker build \
	--build-arg AWS_ACCESS_KEY_ID \
	--build-arg AWS_DEFAULT_REGION \
	--build-arg AWS_SECRET_ACCESS_KEY \
	--build-arg TERRAFORM_VERSION=$(terraform_version) \
	--build-arg TF_VAR_release=$(build) \
	--iidfile $@ \
	--tag sctu/$(name):$(build)-$* \
	--target $* .

apply: .docker/$(build)@plan
	docker run --rm \
	--env AWS_ACCESS_KEY_ID \
	--env AWS_DEFAULT_REGION \
	--env AWS_SECRET_ACCESS_KEY \
	$(shell cat $<)

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker www.sha256sum

up:
	cd www && python -m http.server

www.sha256sum: .docker/$(build)@build
	docker run --rm --entrypoint cat $(shell cat $<) $@ > $@

$(stages): %: .docker/$(build)@%

$(shells): shell@%: .docker/$(build)@% .env
	docker run --rm -it \
	--entrypoint /bin/sh \
	--env-file .env \
	$(shell cat $<)
