build     := $(shell git describe --tags --always)
terraform := latest

.PHONY: all apply clean plan up shell

all: www.sha256sum plan

.docker:
	mkdir -p $@

.docker/$(build): | .docker
	docker build \
	--build-arg AWS_ACCESS_KEY_ID \
	--build-arg AWS_DEFAULT_REGION \
	--build-arg AWS_SECRET_ACCESS_KEY \
	--build-arg TERRAFORM=$(terraform) \
	--build-arg TF_VAR_release=$(build) \
	--iidfile $@ \
	--tag sctu/sctu.net:$(build) .

apply: .docker/$(build)
	docker run --rm \
	--env AWS_ACCESS_KEY_ID \
	--env AWS_DEFAULT_REGION \
	--env AWS_SECRET_ACCESS_KEY \
	$(shell cat $<)

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker www.sha256sum

plan: .docker/$(build)

up:
	ruby -run -e httpd www

www.sha256sum: .docker/$(build)
	docker run --rm --entrypoint cat $(shell cat $<) $@ > $@

shell: .docker/$(build) .env
	docker run --rm -it \
	--entrypoint /bin/sh \
	--env-file .env \
	$(shell cat $<)
