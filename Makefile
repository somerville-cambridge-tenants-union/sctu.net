release ?= $(shell git describe --tags --always)

.PHONY: init plan apply clean

init:
	docker-compose run --rm terraform init

plan:
	docker-compose run --rm -e TF_VAR_release=$(release) terraform plan

apply:
	docker-compose run --rm -e TF_VAR_release=$(release) terraform apply -auto-approve

clean:
	rm -rf .terraform
	docker-compose down --volumes
