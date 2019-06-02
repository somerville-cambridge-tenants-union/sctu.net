# Project
runtime   := ruby2.5
name      := sctu.net
release   := $(shell git describe --tags)
build     := $(name)-$(release)
buildfile := $(build).build
planfile  := $(build).tfplan
syncfile  := www.sha256sum

# Docker Build
image := sctu/$(name)
digest = $(shell cat $(buildfile))

# S3 Deploy
s3_bucket := www.sctu.net
s3_prefix :=

$(planfile): | $(syncfile)
	docker run --rm $(digest) cat /var/task/$@ > $@

$(syncfile): $(buildfile)
	docker run --rm $(digest) cat /var/task/$@ > $@

$(buildfile):
	docker build \
	--build-arg AWS_ACCESS_KEY_ID \
	--build-arg AWS_DEFAULT_REGION \
	--build-arg AWS_SECRET_ACCESS_KEY \
	--build-arg PLANFILE=$(planfile) \
	--build-arg TF_VAR_release=$(release) \
	--iidfile $@ \
	--tag $(image):$(release) .

.PHONY: shell apply clean

shell: $(buildfile)
	docker run --rm -it $(digest) /bin/bash

apply: $(buildfile)
	docker run --rm \
	--env AWS_ACCESS_KEY_ID \
	--env AWS_DEFAULT_REGION \
	--env AWS_SECRET_ACCESS_KEY \
	$(digest) \
	terraform apply $(planfile)

clean:
	docker image rm -f $(image) $(shell sed G *.build)
	rm -rf *.build *.tfplan
