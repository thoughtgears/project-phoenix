.PHONY: terraform

terraform:
	terraform -chdir=terraform init
	terraform -chdir=terraform plan  -out=tf.plan