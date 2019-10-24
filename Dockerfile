ARG TERRAFORM=latest
FROM hashicorp/terraform:${TERRAFORM}
RUN apk add --no-cache python3 && pip3 install awscli
WORKDIR /var/task/
COPY . .
RUN sha256sum www/* | sha256sum > www.sha256sum
ARG AWS_ACCESS_KEY_ID
ARG AWS_DEFAULT_REGION=us-east-1
ARG AWS_SECRET_ACCESS_KEY
ARG TF_VAR_release
RUN terraform fmt -check
RUN terraform init
RUN terraform plan -out terraform.zip
CMD ["apply", "terraform.zip"]
