.env:
	cp $@.example $@

.terraform:
	terraform init

.terraform/terraform.zip: *.tf | .terraform
	terraform fmt -check
	terraform plan -out $@

.PHONY: default apply cachebust clean plan up sync

default: plan

apply: .terraform/terraform.zip
	terraform apply $<

cachebust: | .terraform
	aws cloudfront list-distributions --query 'DistributionList.Items[].Id' --output text \
	| xargs aws cloudfront create-invalidation --paths '/*' --distribution-id

clean:
	rm -rf .terraform

plan: .terraform/terraform.zip

up:
	@echo 'Starting server on http://localhost:8080/'
	ruby -run -e httpd www

sync:
	aws s3 sync www s3://www.sctu.net/
