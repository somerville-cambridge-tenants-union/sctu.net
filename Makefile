release ?= $(shell git describe --tags --always)
files = $(shell aws s3 ls s3://www.sctu.net/ | awk '{print $$4}' | sed 's/^/\//g' | tr '\n' ' ')
distribution_id = $(shell terraform output cloudfront_distribution_id)

.PHONY: init plan apply invalidations server clean

.terraform:
	docker-compose run --rm terraform init

init: .terraform

plan: init
	docker-compose run --rm -e TF_VAR_release=$(release) terraform plan

apply: init
	docker-compose run --rm -e TF_VAR_release=$(release) terraform apply -auto-approve

invalidations:
	aws cloudfront create-invalidation --distribution-id $(distribution_id) --paths $(files)

server:
	python -m http.server --directory sctu.net

clean:
	rm -rf .terraform
	docker-compose down --volumes
