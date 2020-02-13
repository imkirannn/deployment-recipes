terraform {
  backend "s3" {
   shared_credentials_file = "/opt/mywork/Terraform/.aws/credentials"

  }
}

provider "aws" {
  region                  = "eu-west-2"
  shared_credentials_file = "/opt/mywork/Terraform/.aws/credentials"
  profile                 = "default"
}
locals {
  azs                    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  environment            = "dev"
  kops_state_bucket_name = "${local.environment}-kops-state-blog"

  # Needs to be a FQDN
  kubernetes_cluster_name = "k8s-dev.rrproject.club"
  ingress_ips             = ["10.0.0.100/32", "10.0.0.101/32"]
  vpc_name                = "${local.environment}-vpc"

  tags = {
    environment = local.environment
    terraform   = true
  }
}

data "aws_region" "current" {
}

