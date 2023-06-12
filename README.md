# sdp-infrastructure
## Summary
The following tasks has been completed.
- Kubernetes cluster (EKS) created end to end using terraform.
- Dockerized the application and deployed as autoscaling kubernetes pods.
- MongoDB running as pods.
- [Screenshots](screenshots.md)
- [Commands used](#Commands-and-Usage:-Build-and-deployment-operations)  
- Kuberenetes components are deployed using helm charts and terraform helm provider.
- Created EC2 ami using Packer and is being used for EKS nodes.
- Secuirity is considered in every stage of the design. More information here.
- Avoided single point of failures.
- Scalability is considered in every stage of the design. More information here.
- Created Ansible scripts to validate a few services.
- Created an overlay Makefile to simplify various build and deployment activities enabling single button deployments or gitOps through CICD integration.
- Added a simple prometheus+grafana observability stack.
## Architecture
I used a simple three tier architecture with the application loadbalancers in public facing subnets and other components (application and database) deployed in private subnets. A very high level architecture is as shown in the image.
![hl-architecture](https://github.com/anoopvm/sdp-infrastructure/assets/24317749/3878f531-ca63-42de-a460-d3be756bae8b)
## Code Overview
All resources created as part of the excercise is through Infrastructure as Code. Manual interference is limited to version management of certain components like helm charts, ami version etc. These could be automated as well but are avoided by design to enable better version control practices and code (IaC) reviews.
Contents of each folder/file as below:
<br><br>**terraform:** The terraform folder contains all the modules used for EKS cluster creation, roles, ingress controller and a few helm releases (monitoring stack).
<br><br>**helm:** Helm charts for devops practical web app deployment and the mongodb pods. It also contains a reusable ingress helm chart which can be used by other modules.
<br><br>**docker:** Docker file used for dockerizing devops practical web app.
<br><br>**images:** Packer file used for custom ami creation.
<br><br>**ansible:** Ansible script to do a quick sanity check on instances created using the custom image.
<br><br>**release-conifgs:** Single place for all the configurations. This is the only place where any configuration changes are made. Tried to make the configs as simple as possible by exposing only required configurations. As the project grows more configs can be exposed here as required. This folder also segragates the configuration for each environment (dev, staging, production etc).
<br><br>**Makefile:** Single entrypoint for all the build and deployment activities for this exercise.
## Components
#### EKS Cluster
- One EKS cluster spanning across two availability zones. Currently configured for us-east-1a and us-east-1b. Easy to change the configuration for different regions.
- The web application and database are deployed in private subnet and is only accessbile to a public subnet through Application load balancers.
- Routes are configured using ALB ingress contoller.
- End to End deployment is managed using idempotent Infrastructure as Code. Terraform, helm charts, and eksctl are used.
- Minimal configs and single 'make' command to build EKS cluster from scratch. Easy to deploy using CICD tools.
- Kubernetes control plane access is through OIDC token only.
- Instance access is managed by AWS SSM. No external or internal SSH service access.
- Seperate autoscaling group for app tier and data tier enabling efficient scaling strategy.
#### Devops Practical web app
- Deployed as stateless horizontally scalable deployments accessible from a load balancer.
- SSL/TLS handshake happens at ALB using ACM certificates.
- http connections are redirected to https even before reaching the application.
- Horizontal pod autoscaling enabled.
- Configured with liveliness and readiness probes for fault-tolerance.
- Configured with security contexts to avoid container privilage escalations.
- Pods are spread across availability zones using the topology spread constraints.
- Deployed using helm charts managed by versioned releases.
#### Mongodb
- Deployed CRDs from mongodb community operator - https://github.com/mongodb/mongodb-kubernetes-operator
- The mongodb operator provides a lot of features out of the box like:
  - Mongodb replicasets
  - Scaling up and down
  - Version upgrade and downgrade
  - Authentication
  - Monitoring
- The endpoints are accessbile only within kubernetes.
- Credentials are handled using AWS secrets during deployment.
- EBS volumes are created using EBS CSI drivers on demand. Statefulset replicas retains EBS volumes.
- Pods are spread across availability zones using the topology spread constraints.
- Deployed using helm charts managed by versioned releases.
#### Custom AWS AMI
- Created a custom AWS AMI for the pupose of this exercise only.
  - AWS images use chronyd for time synchronization- https://chrony.tuxfamily.org/
  - Changed the default time synchornyzation deamon to ntpd for the purpose of custom AMI creation.
- The image version is managed using explicit versions similar to the Helm's recommendations. 
- This enables to use different versions of images in different environment.
- Simplified validation, linting and building image all through single 'make' command.
#### Ansible Sanity check
- Dynamic aws inventory creation using ec2_aws plugin.
- Dynamic inventory avoids outdated inventories especially useful for EKS and autoscling environments.
- Checks status of services like ntpd, container runtime, and kubelet etc.
- Run through single 'make' command.
### Design considerations
Following criterias were considered during the design also lists various approaches implemented and possible improvements.
##### Scalability
- Two seperate autoscaling groups.
  - One for app tier (devops practical webapp)
  - Another one for the data tier (Mongo DB)
  - This allows more efficient handling of horizontal scaling. 
  - Ability to choose different EC2 instance types that matches memory to CPU ratio.
- The EKS module provides the provision to enable cluster autoscaler but not enabled currently for this exercise.
- Horizontal Pod autoscaler enabled for the web application pod.
- Mongodb operator provides replicaset scaling features. But require additional tooling and benchmarking.
##### Availability
- Avoided all single point of failures for the core applications.
- The EKS cluster is deployed in 2 availability zones for extra availability.
- Pods are topologically spread across the 2 availability zones for extra availability.
- Horizontal pod autoscaler provides availabiltiy in case of peak usage.
- Traffic is load balanced using AWS ALB which provides high availability as a managed feature.
- Enabled fault-tolerance mechanisms like liveliness and readyness probe for core applications.
- Features like data backup, additonal fault-tolerance, self-healing, etc can be implemented using additonal tooling using monitoring stack, AWS lambda etc.
##### Security
- Followed best practices in creating and deploying containers like security contexts, limits root privilage, reduce surface area, etc.
- Secrets are managed using AWS secrets manager and handled using terraform's and helm's sensitive features.
- Security groups are used to protect subnet access.
- Configured SCRAM based authentication for Mongodb access.
- Strict role based access is implemented using AWS IAM roles and policies for all the components.
- Sperate tiers for app and data configured making it one step closer to implement network segmentation. Network segmentation is not implemented due to time limitation as of now.
- Some credentials are still stored as kubernetes secrets. In production environments this should be avoided by enabling the applicaiton to get secrets from AWS secret manager or Vault directly.
- Code scanning and image scanning must be implemented as part of build process. This is not included currently.
- Pod security policy must be implemented to contol access between pods. This is not included currently.
##### Operational efficiency
- The whole Infrastructure as Code follows declarative approach and idempotency rather than an imperative approach.
- Created easy to use overlay using Linux native Makefiles which maked operations easier.
- The Makefile also makes it easy to stitch with CICD pipelines triggered using gitOps.
- Tried to demonstrate version based IaC bundles which is a key feature to enable gitOps. Eg. version helm charts.
- Currently some code is not bundled using version as part of this exercise, but it can be easily extended using git releases/tags  and an extra git repository for realease configs.
- A docker based virtual environment can be easily created to make development, testing, or deployment easier. Not included currently.
## Commands and Usage: Build and deployment operations
The following operation list all the available build and deployment operations
```
$ make [TAB]
build-app              build-packer-image     deploy-infra           build-docker
build-infra            deploy-app             destroy-infra          instance-sanity-check
```
Usage of each make rule along with required configurations is listed below
### build-docker
Builds the docker image by cloning the code repository and push to the docker repository.
Prerequistes:
- Docker engine must be installed.
- Must be authenticated to push to the docker repo.
- Choose a new version for the docker image.

Usage:
```
make build-docker VERSION=v0.0.1
```
### build-packer-image
Builds new aws ami. Packer file is images/eks_node_instance.pkr.hcl. After making changes, if any, please update the new version before building in local.version at the beginning.
```
locals {
  version    = "v0.0.2"
  image_name = "eks-instance-${local.version}"
}
  . . .
```
Prerequesites:
- Packer must be installed.
- Version updated in the packer file (If making any change.)

Usage:
```
make build-packer-image
```
### build-infra
This will only lint, validate and plan terrafrom for all the cloud infrastructure like VPC, subnets, EKS cluster, security groups, roles, addons, etc. This will not deploy any infrastructure. This is for review purpose and could be used for peer reviews before deployment.

The following configurations are required for this command.
```
region = "us-east-1"
tags = {
  Terraform        = "true"
  billing_category = "default"
}

## Network Infra Configs
vpc_name                  = "staging-sdp"
cidr                      = "10.0.0.0/16"
azs                       = ["us-east-1a", "us-east-1b"]
app_tier_private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
data_tier_private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
public_subnets            = ["10.0.101.0/24", "10.0.102.0/24"]

## EKS Variables
ami_name        = "eks-instance"
ami_version     = "v0.0.2"
eks_name          = "staging-sdp"
public_access_ips = ["XX.XX.XX.XX/XX"]
```
The configuration file is under respective environment in ```release-configs``` folder.
```
$ ls release-configs/
dev  production  staging
```
For example here is the file for staging environment
```release-configs/staging/infrastructure-terraform.tfvars```

Prerequisites:
- If you build a packer image please update `ami_version`.
- The public_access_ips must be updated with your IP or cidr block.
- All the other default values should work.
- Terraform must be installed.
- Helm must be installed.
- AWS cli must be installed.
- AWS authentication must be setup either using one of the methods mentioned here - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html

Usage:
```
make build-infra ENV=<dev|staging|prod>
```
### deploy-infra
This deploys all cloud resources and required addons.

Prerequisites:
- No other prerequisites if build-infra is run successfully. It is recommended to run build-infra first and review the changes first.

usage:
```
make deploy-infra ENV=<dev|staging|prod>
```
### build-app
Like build-infra this only do validation and terraform plan for all the kubernetes manifests declared in helm charts.
The following configurations are required. Helm recommends to use versioned charts, usually resides in Chart.yaml. Terraform uses that version for maintaining its idempotent nature. The helm chart must be versioned in respective Chart.yaml if making any change and must be updated in `release-configs/<dev|staging|prod>/application-terraform.tfvars`. `certificate_arn` is the ACM certificate arn (Only supports ACM certificates currently, refer HERE#####). `sdp_namepace` is the namespace where the devops practical web-app will be deployed.
```
## Application Variables
sdp_namespace = "sdp"
sdp_helm_version   = "0.1.7"
sdp_docker_version = "v0.0.1"
certificate_arn = "arn:aws:acm:us-east-1:111111111:certificate/dbec3dd3-b823-47bc-9549-99a2d1b25e56"
```
Prerequisites:
- Infrastructure must be deployed using `deploy-infra`
- kubectl must be installed.

Usage:
```
make build-app ENV=<dev|staging|prod>
```
### deploy-app
Deploys the kubernetes resources mentioned in `build-app`.

Prerequisites:
- No prerequisites required if `build-app` is run. It is recommended to run build-app first.
Usage:
```
make deploy-app ENV=<dev|staging|prod>
```
### instance-sanity-check
Run ansible playbook to validate if ntp and a few other services like kubelet and containerd up and running.
Prerequisites:
- Ansible must be installed.
- AWS authentication must be done as mentioned here - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html

Usage:
```
make instance-sanity-check
```
### destroy-infra
Delete EKS cluster, network infrastructure and other cloud components.
Prerequisites:
- Same as `build-deploy`
Usage:
```
make destroy-infra
```
