.env:
	cp $@.example $@

.terraform:
	terraform init

terraform.zip: | .terraform
	terraform plan -out $@

.PHONY: default apply cachebust clean plan up sync

default: plan

apply: terraform.zip
	terraform apply $<

cachebust: | .terraform
	terraform output cloudfront_distribution_id \
	| xargs aws cloudfront create-invalidation --paths '/*' --distribution-id

clean:
	rm -rf .terraform terraform.zip

plan:
	terraform plan

up:
	@echo 'Starting server on http://localhost:8080/'
	ruby -run -e httpd www

sync:
	aws s3 sync www s3://www.sctu.net/
