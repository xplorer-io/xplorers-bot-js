
SHELL = /bin/bash
SHELLFLAGS = -ex

VERSION ?= $(shell git rev-parse --short HEAD)
DEPLOYED_AT := $(shell date)
GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
API_STAGE ?= dev
CFN_BUCKET = xplorersbot-configuration-bucket

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

build: ## Install dependencies, build the artifact
	$(info [+] Running package build...)
	scripts/build.sh
.PHONY: build

cleanup: ## Cleanup build files
	@rm -rf *.packaged.yml cloudformation/lambda.zip
.PHONY: cleanup

deploy-xplorers-bot: ## Deploy Xplorers Bot to AWS
	$(info [+] Deploying Xplorers bot to AWS....)
	@aws cloudformation package \
		--s3-bucket $(CFN_BUCKET) \
		--s3-prefix xplorersbot/$(GIT_BRANCH)/$(VERSION) \
		--template-file cloudformation/xplorersbot.yml \
		--output-template-file xplorersbot.packaged.yml
	@aws cloudformation deploy \
		--s3-bucket $(CFN_BUCKET) \
		--s3-prefix xplorersbot/$(GIT_BRANCH)/$(VERSION) \
		--template-file xplorersbot.packaged.yml \
		--stack-name xplorersbot-$(GIT_BRANCH)-deploy \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--parameter-overrides \
			StageName=$(API_STAGE) \
		--tags xplorersbot:version=$(VERSION) xplorersbot:branch=$(GIT_BRANCH)
	@make cleanup
	@echo 'Deployed at: $(DEPLOYED_AT)'
.PHONY: deploy-xplorers-bot
