ifneq (,$(wildcard .env))
include .env
export $(shell sed 's/=.*//' .env)
endif

PAB_POLICY_ID=dr-project-access

.PHONY: pab terraform dev deploy

pab:
	$(eval PROJECT_ID := $(shell terraform -chdir=terraform output -json | jq -r '.project_info.value.target.id'))
	@if gcloud beta iam principal-access-boundary-policies describe $(PAB_POLICY_ID) --organization=$(ORGANIZATION_ID) --location=global > /dev/null 2>&1; then \
		echo "Policy $(PAB_POLICY_ID) already exists, skipping creation."; \
	else \
		echo "Creating policy $(PAB_POLICY_ID)"; \
		pip install -r resources/scripts/requirements.txt; \
		python resources/scripts/generate_pab_policy.py --policy_id $(PAB_POLICY_ID) --project $(PROJECT_ID); \
		gcloud beta iam principal-access-boundary-policies create $(PAB_POLICY_ID) \
			--organization=$(ORGANIZATION_ID) \
			--location=global \
			--display-name=$(PAB_POLICY_ID) \
			--details-rules=resources/pab-policies/project-access-policy.json \
			--details-enforcement-version=latest; \
	fi

	@if gcloud beta iam policy-bindings describe $(PAB_POLICY_ID) --organization=$(ORGANIZATION_ID) --location=global > /dev/null 2>&1; then \
		echo "Policy binding $(PAB_POLICY_ID) already exists, skipping creation."; \
	else \
		echo "Creating policy binding $(PAB_POLICY_ID)"; \
		gcloud beta iam policy-bindings create $(PAB_POLICY_ID) \
			--organization=$(ORGANIZATION_ID) \
			--location=global \
			--policy="organizations/$(ORGANIZATION_ID)/locations/global/principalAccessBoundaryPolicies/$(PAB_POLICY_ID)" \
			--target-principal-set=//iam.googleapis.com/locations/global/workspace/$(WORKSPACE_ID) \
			--display-name=$(PAB_POLICY_ID) \
			--condition-title="dr-group" \
			--condition-description="Only allow access to the project if in dr group" \
			--condition-expression="principal.type == 'iam.googleapis.com/WorkspaceIdentity' && 'principal.subject.startsWith(\"gcp-backup-admins\")'"; \
	fi

terraform:
	cd terraform && tflint --recursive
	terraform -chdir=terraform init
	terraform -chdir=terraform plan  -out=tf.plan
	terraform -chdir=terraform apply tf.plan

dev:
	@functions-framework --target=backup --host=0.0.0.0 --port=8080 --signature-type=http --debug

deploy:
	$(eval BUCKET_NAME := $(shell terraform -chdir=terraform output -json | jq -r '.phoenix_backup_bucket.value'))
	$(eval SERVICE_ACCOUNT := $(shell terraform -chdir=terraform output -json | jq -r '.phoenix_cloud_function_service_account_email.value'))
	$(eval PROJECT_ID := $(shell terraform -chdir=terraform output -json | jq -r '.project_info.value.source.id'))
	@gcloud functions deploy phoenix-backup \
	--runtime python312 \
	--trigger-http \
	--no-allow-unauthenticated \
	--entry-point backup \
	--service-account $(SERVICE_ACCOUNT) \
	--set-env-vars BUCKET_NAME=$(BUCKET_NAME) \
	--memory 128MB \
	--timeout 60s \
	--region $(REGION) \
	--project $(PROJECT_ID) \
	--no-gen2 \
	--quiet