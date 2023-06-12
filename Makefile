common_config_file = ../../release-configs/common/common-terraform.tfvars
infrastructure_root = terraform/infrastructure
infrastructure_config_file = ../../release-configs/$(ENV)/infrastructure-terraform.tfvars
application_root = terraform/applications
application_config_file = ../../release-configs/$(ENV)/application-terraform.tfvars
tf_backend = ../../release-configs/common/backend.conf
infrastructure_var_files = --var-file=$(infrastructure_config_file) --var-file=$(common_config_file)
application_var_files = --var-file=$(application_config_file) --var-file=$(common_config_file)

select-workspace = terraform workspace new $(ENV); \
	terraform workspace select $(ENV); \
	terraform workspace show $(ENV)

init-validate = terraform init -backend-config=../../release-configs/common/backend.conf; \
	terraform fmt -recursive; \
	terraform validate

build-infra:
	cd $(infrastructure_root); \
	$(select-workspace); \
	$(init-validate); \
	terraform plan $(infrastructure_var_files) --var=aws_profile=$(ENV)

deploy-infra:
	cd $(infrastructure_root); \
	$(select-workspace); \
	terraform apply --auto-approve $(infrastructure_var_files) --var=aws_profile=$(ENV)

destroy-infra:
	cd $(infrastructure_root); \
	$(select-workspace); \
	terraform destroy --auto-approve  --var=aws_profile=$(ENV)

build-docker:
	cd docker;\
	sudo docker build . -t anoopvm/sdp-app:$(VERSION);\
	sudo docker push anoopvm/sdp-app:$(VERSION)

build-app:
	cd $(application_root); \
	$(select-workspace); \
	$(init-validate); \
	terraform plan $(application_var_files) --var=aws_profile=$(ENV)

deploy-app:
	cd $(application_root); \
	$(select-workspace); \
	terraform apply --auto-approve $(application_var_files) --var=aws_profile=$(ENV)

build-packer-image:
	cd images; \
	packer fmt .; \
	packer validate .; \
	packer build eks_node_instance.pkr.hcl;

instance-sanity-check:
	cd ansible; \
	ansible-playbook -i hosts.aws_ec2.yaml health_check.yaml
