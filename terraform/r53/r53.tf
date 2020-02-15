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
  name = "kubernetes_cluster_name"

  vpc {
    vpc_id = "${vpc_id}"
  }

}

locals {
    my_office_ip = "0.0.0.0/0"
}
resource "aws_security_group" "allow_ssh" {
        vpc_id = "${module.dev_vpc.vpc_id}"
        name = "allow_all"
        description = "Allow inbound SSH traffic from my IP"

        ingress {
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["${local.my_office_ip}"]
        }
         egress {
                from_port       = 0
                to_port         = 0
                protocol        = "-1"
                cidr_blocks     = ["0.0.0.0/0"]
        }
        tags = {
                Name = "Allow SSH"
        }
}
