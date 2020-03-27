REPO      := sctu/sctu.net
TERRAFORM := latest
BUILD     := $(shell date +%Y.%-m.%-d)

.PHONY: default apply clean clear clobber plan up shell sync

default: plan

.docker:
	mkdir -p $@

.docker/$(BUILD): Dockerfile terraform.tf | .docker
	docker build \
	--build-arg AWS_ACCESS_KEY_ID \
	--build-arg AWS_DEFAULT_REGION \
	--build-arg AWS_SECRET_ACCESS_KEY \
	--build-arg TERRAFORM=$(TERRAFORM) \
	--build-arg TF_VAR_VERSION=$(BUILD) \
	--iidfile $@ \
	--tag $(REPO) \
	.

.env:
	cp $@.example $@

apply: .docker/$(BUILD)
	docker run --rm \
	--env AWS_ACCESS_KEY_ID \
	--env AWS_DEFAULT_REGION \
	--env AWS_SECRET_ACCESS_KEY \
	$$(cat $<)

clean:
	rm -rf .docker www.sha256sum

clear:
	aws cloudfront create-invalidation --distribution-id $$(terraform output cloudfront_distribution_id) --paths '/*'

clobber: clean
	docker image ls $(REPO) --quiet | xargs docker image rm --force

plan: .docker/$(BUILD)

up:
	ruby -run -e httpd www

terraform.tfvars:
	echo 'VERSION = "$(BUILD)"' > $@

shell: .docker/$(BUILD) .env
	docker run --rm -it --entrypoint sh --env-file .env $$(cat $<)

sync:
	aws s3 sync www s3://$$(terraform output bucket_name)/
