provider "aws" {
  region                  = "eu-west-2"
  shared_credentials_file = "/opt/mywork/Terraform/.aws/credentials"
  profile                 = "default"
}
module "dev_vpc" {
 source = "../modules/dev_vpc"
 create_vpc = false
}

resource "aws_route53_zone" "private" {
  name = outputs.kubernetes_cluster_name

  vpc {
    vpc_id = module.dev_vpc.vpc_id
  }

}
