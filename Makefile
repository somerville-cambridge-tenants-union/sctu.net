BUILD := $(shell date +%Y.%-m.%-d)

.env:
	cp $@.example $@

.terraform:
	terraform init

# terraform.tfvars:
# 	echo 'VERSION = "$(BUILD)"' > $@

.PHONY: default apply clear clobber plan up shell sync

default: plan

apply plan: | .terraform
	terraform $@

clear: | .terraform
	aws cloudfront create-invalidation --distribution-id $$(terraform output cloudfront_distribution_id) --paths '/*'

up:
	ruby -run -e httpd www

sync:
	aws s3 sync www s3://www.sctu.net/
