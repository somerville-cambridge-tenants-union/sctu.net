.env:
	cp $@.example $@

.terraform:
	terraform init

.PHONY: default apply cachebust plan up sync

default: plan

apply plan: | .terraform
	terraform $@

cachebust: | .terraform
	terraform output cloudfront_distribution_id \
	| xargs aws cloudfront create-invalidation --paths '/*' --distribution-id

up:
	@echo 'Starting server on http://localhost:8080/'
	ruby -run -e httpd www

sync:
	aws s3 sync www s3://www.sctu.net/
