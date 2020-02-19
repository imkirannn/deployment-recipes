terraform {
  backend "s3" {

  }
}

provider "aws" {
  region                  = "eu-west-2"
  profile                 = "default"
}
locals {
  azs                    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  environment            = "dev"
  kops_state_bucket_name = "${local.environment}-kops-state-blog-1"
  my_office_ip	     = "0.0.0.0/0"

  # Needs to be a FQDN
  kubernetes_cluster_name = "test.cloudhands.online"
 # ingress_ips             = ["10.0.0.100/32", "10.0.0.101/32"]
#   ingress_ips		 = 
  vpc_name                = "${local.environment}-vpc"
  repository_name 	  = "cloudhands/demo-app"

  tags = {
    environment = local.environment
    terraform   = true
  }
}

data "aws_region" "current" {
}

