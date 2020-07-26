.DEFAULT_GOAL := help

TERRAFORM_VERSION := 0.12.29
DOCKER_OPTIONS := -v ${PWD}:/work \
-w /work \
-it \
-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

init: ## Initialize the Terraform state:  make init
	@docker run ${DOCKER_OPTIONS} hashicorp/terraform:${TERRAFORM_VERSION} init -upgrade=true

plan: ## Run a Terraform plan:  make plan
	@docker run ${DOCKER_OPTIONS} hashicorp/terraform:${TERRAFORM_VERSION} plan

apply: ## Create the resources with website:  make apply
	@docker run ${DOCKER_OPTIONS} hashicorp/terraform:${TERRAFORM_VERSION} apply -auto-approve

url: ## Output resource attributes:  make output
	@docker run ${DOCKER_OPTIONS} hashicorp/terraform:${TERRAFORM_VERSION} output cloudfront_domain_name

copy_website_files: ## Copy the static website files up to S3: make copy_website_files
	@docker run ${DOCKER_OPTIONS} ccliver/awscli aws s3 sync website-files/ s3://$(shell cat terraform.tfstate | jq -r .outputs.bucket_name.value)/ > /dev/null

adhoc: ## Run an ad hoc Terraform command: COMMAND=version make adhoc
	@docker run ${DOCKER_OPTIONS} hashicorp/terraform:${TERRAFORM_VERSION} ${COMMAND}

destroy: ## Destroy the AWS resources with Terraform: make destroy
	@docker run ${DOCKER_OPTIONS} hashicorp/terraform:${TERRAFORM_VERSION} destroy

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
