infrastructure_root = terraform/infrastructure
infrastructure_config_file = ../../release-configs/$(ENV)/infrastructure-terraform.tfvars
application_root = terraform/applications
application_config_file = ../../release-configs/$(ENV)/application-terraform.tfvars

build-infra:
	cd $(infrastructure_root); \
        terraform init; \
        terraform fmt -recursive; \
        terraform validate; \
        terraform plan --var-file=$(infrastructure_config_file)

deploy-infra:
	cd $(infrastructure_root); \
	terraform apply --auto-approve --var-file=$(infrastructure_config_file)

destroy-infra:
	cd $(infrastructure_root); \
	terraform destroy --auto-approve

docker-build:
	cd docker;\
	sudo docker build . -t anoopvm/sdp-app:$(VERSION);\
	sudo docker push anoopvm/sdp-app:$(VERSION)

build-app:
	cd $(application_root); \
        terraform init; \
	terraform fmt -recursive; \
	terraform validate; \
	terraform plan --var-file=$(application_config_file)

deploy-app:
	cd $(application_root); \
	terraform apply --auto-approve --var-file=$(application_config_file)

build-packer-image:
	cd images; \
	packer fmt .; \
	packer validate .; \
	packer build eks_node_instance.pkr.hcl;

instance-sanity-check:
	cd ansible; \
	ansible-playbook -i hosts.aws_ec2.yml health_check.yaml
