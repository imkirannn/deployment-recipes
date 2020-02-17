resource "aws_eip" "nat" {
  count = 1 

  vpc = true
}
module "dev_vpc" {
  source             = "./modules/dev_vpc"
  name               = local.vpc_name
  cidr               = "10.0.0.0/16"
  azs                = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  single_nat_gateway  = true
  reuse_nat_ips       = true                     
  external_nat_ip_ids = aws_eip.nat.*.id

  tags = {
    // This is so kops knows that the VPC resources can be used for k8s
    "kubernetes.io/cluster/${local.kubernetes_cluster_name}" = "shared"
    "terraform"                                              = true
    "environment"                                            = local.environment
  }

  // Tags required by k8s to launch services on the right subnets
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = true
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = true
  }
}

