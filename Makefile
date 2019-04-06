release ?= $(shell git describe --tags --always)

.PHONY: init plan apply server clean

.terraform:
	docker-compose run --rm terraform init

init: .terraform

plan: init
	docker-compose run --rm -e TF_VAR_release=$(release) terraform plan

apply: init
	docker-compose run --rm -e TF_VAR_release=$(release) terraform apply -auto-approve

server:
	python -m http.server --directory sctu.net

clean:
	rm -rf .terraform
	docker-compose down --volumes
