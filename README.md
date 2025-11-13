# Terraform AWS module

A repo of generic abstract modules to meet mostly my needs for both personal and professional project. Many of these modules are simple wrappers of resources to help keep code tidy. Like a Security group that allows the definition of ingress/egress rules in the same block while allowing separated rules to still be added.

In addition, the tests folders serve the other purpose to provide examples of how to use the modules. For example, the vpc module has examples for internal only vpc's or a public/private subnet vpc with ipv6 ingress capability

## The modules

* [asg-service](./modules/asg-service/README.md)
* [cert](./modules/cert/README.md)
* [code-build](./modules/code-build/README.md)
* [code-pipeline](./modules/code-pipeline/README.md)
* [cognito](./modules/cognito/README.md)
* [dyanmo-db](./modules/dyanmo-db/README.md)
* [fargate-service](./modules/fargate-service/README.md)
* [kms-key](./modules/kms-key/README.md)
* [lambda](./modules/lambda/README.md)
* [lambda-s3-ui](./modules/lambda-s3-ui/README.md)
* [lambda-with-api](./modules/lambda-with-api/README.md)
* [load-balancer](./modules/load-balancer/README.md)
* [power-tools](./modules/power-tools/README.md)
* [rds](./modules/rds/README.md)
* [rotate-admin-rds-pw](./modules/rotate-admin-rds-pw/README.md)
* [s3-bucket](./modules/s3-bucket/README.md)
* [s3-site](./modules/s3-site/README.md)
* [scheduled-task](./modules/scheduled-task/README.md)
* [secrets](./modules/secrets/README.md)
* [security-group](./modules/security-group/README.md)
* [serverless-app](./modules/serverless-app/README.md)
* [sns](./modules/sns/README.md)
* [sqs](./modules/sqs/README.md)
* [start-stop](./modules/start-stop/README.md)
* [task-definition](./modules/task-definition/README.md)
* [vpc](./modules/vpc/README.md)

## The tests folder

This folder just contains all of the tests used to validate the modules. This is far from complete currently but will contain examples of how to create a whole system

## Docker

To aid in development, the docker file is just a development container which installs node, sops, aws, tenv, terragrunt, and open tofu. This is to reduce the amount of software needed to install in order to test and develop these modules

## Required Software

| Name | Version | 
|------|:---------:|
| Sops | ==3.11.0 |
| GoLang | >=1.25.3 |
| Python | >= 3.10.0 |
| nvm | ==0.40.3 |
| packer | >= 1.14.2 |
| tenv | ==v4.7.21 |
| tfdocs | ==0.20.0 |
| opentofu | ==1.10.6 |
| terragrunt | ==0.91.5 |