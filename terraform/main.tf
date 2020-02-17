terraform {
  backend "s3" {
   shared_credentials_file = "/opt/mywork/Terraform/.aws/credentials1"

  }
}

provider "aws" {
  region                  = "eu-west-2"
  shared_credentials_file = "/opt/mywork/Terraform/.aws/credentials1"
  profile                 = "default"
}
locals {
  azs                    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  environment            = "dev"
  kops_state_bucket_name = "${local.environment}-kops-state-blog"
  my_office_ip	     = "0.0.0.0/0"

  # Needs to be a FQDN
  kubernetes_cluster_name = "k8s-dev.cloudhands.online"
  ingress_ips             = ["10.0.0.100/32", "10.0.0.101/32"]
  vpc_name                = "${local.environment}-vpc"
  repository_name 	  = "cloudhands/demo-app"

  tags = {
    environment = local.environment
    terraform   = true
  }
}

data "aws_region" "current" {
}

