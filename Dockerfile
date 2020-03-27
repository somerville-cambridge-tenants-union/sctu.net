ARG TERRAFORM=latest
FROM hashicorp/terraform:${TERRAFORM}
RUN apk add --no-cache python3 && pip3 install awscli
WORKDIR /var/task/
COPY . .
ARG AWS_ACCESS_KEY_ID
ARG AWS_DEFAULT_REGION=us-east-1
ARG AWS_SECRET_ACCESS_KEY
RUN terraform fmt -check
RUN terraform init
ARG TF_VAR_VERSION
RUN terraform plan -out terraform.zip
CMD ["apply", "terraform.zip"]
