provider "aws" {
  region                  = "eu-west-2"
  shared_credentials_file = "/opt/mywork/Terraform/.aws/credentials"
  profile                 = "default"
}
module "dev_vpc" {
 source = "../modules/dev_vpc"
 create_vpc = false
}

data "template_file" "script1" {
   template = "${file("setup_env.sh")}"
}

data "template_file" "script2" {
   template = "${file("setup_cluster.sh")}"
}

data "template_cloudinit_config" "config" {
   gzip = false
   base64_encode = true

   part {
     filename = "setup_env.sh"
     content_type = "text/part-handler"
     content = "${data.template_file.script1.rendered}"
  }

  part {
    filename = "setup_cluster.sh"
    content_type = "text/part-handler"
    content = "${data.template_file.script2.rendered}"
  }
}



data "aws_ami" "ubuntu" {
	most_recent = true
	filter {
		name = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
	}
	filter {
		name = "virtualization-type"
		values = ["hvm"]
	}
	owners = ["099720109477"]
}
resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-demo"
  public_key = "${file("terraform-demo.pub")}"
}
locals {
    my_office_ip = "182.75.83.2/32"
}
resource "aws_security_group" "allow_ssh" {
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
resource "aws_instance" "web" {
	ami = "${data.aws_ami.ubuntu.id}"
	instance_type = "t2.micro"
	count = "1"
//	subnet_id = module.dev_vpc.public_subnets
//	subnet_id = "${element(data.terraform_remote_state.network.outputs.public_subnet_ids,0)}"
//	subnet_id = element(split(",", data.terraform_remote_state.network.outputs.public_subnet_ids), 0)
        subnet_id = element(split(",", join(",",module.dev_vpc.public_subnets)), 0)
//	subnet_id = tostring(data.terraform_remote_state.network.outputs.public_subnet_ids[0])
//	subnet_id = aws_subnet.outputs.public_subnets
       // subnet_id = module.dev_vpc.public_subnets[0]
	iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
	key_name = "${aws_key_pair.terraform-demo.key_name}"
	//user_data = "${file("setup_env.sh")}"
        user_data     = "${data.template_cloudinit_config.config.rendered}"
	security_groups = [ "${aws_security_group.allow_ssh.name}" ]
	tags = {
		Name = "my-test-server-${count.index}"
	}
	provisioner "remote-exec" {
    		inline = [
			"touch a.txt",
        		"git clone https://github.com/imkirannn/deployment-recipes.git",
                ]	
	}
	connection {
   		 host = "${self.public_ip}"
   		 type     = "ssh"
		 user     = "ubuntu"
		 password = ""
	    	 private_key = "${file("terraform-demo")}"
  	}
	depends_on = [aws_iam_role_policy.test_policy]
}
