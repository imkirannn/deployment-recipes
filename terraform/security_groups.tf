// Used to allow web access to the k8s API ELB
resource "aws_security_group" "k8s_common_http" {
  name   = "${local.environment}_k8s_common_http"
  vpc_id = module.dev_vpc.vpc_id
  tags   = merge(local.tags)

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["${local.my_office_ip}"]
  }

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["${local.my_office_ip}"]
  }
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
