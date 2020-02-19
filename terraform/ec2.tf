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
  public_key = "${file("${path.module}/terraform-demo.pub")}"
}


resource "aws_instance" "web" {
	ami = "${data.aws_ami.ubuntu.id}"
	instance_type = "t2.micro"
	count = "1"
//	subnet_id = module.dev_vpc.public_subnets
//	subnet_id = "${element(data.terraform_remote_state.network.outputs.public_subnet_ids,0)}"
//	subnet_id = element(split(",", data.terraform_remote_state.network.outputs.public_subnet_ids), 0)
        subnet_id = element(split(",", join(",","${module.dev_vpc.public_subnets}")), 0)
//	subnet_id = tostring(data.terraform_remote_state.network.outputs.public_subnet_ids[0])
//	subnet_id = element(public_subnet_ids.*.ids ,0)
       // subnet_id = module.dev_vpc.public_subnets[0]
	iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
	
	key_name = "${aws_key_pair.terraform-demo.key_name}"
	user_data = "${file("setup_env.sh")}"
       // user_data     = "${data.template_cloudinit_config.config.rendered}"
	vpc_security_group_ids = [ "${aws_security_group.allow_ssh.id}" ]
	tags = {
		Name = "my-test-server-${count.index}"
	}
//	disable_api_termination = "true"
	provisioner "remote-exec" {
    		inline = [
			"touch a.txt",
        		"git clone -b kitta https://github.com/imkirannn/deployment-recipes.git",
			"sleep 200",
			"~/deployment-recipes/kubernetes-cluster/regen-cluster.sh"
                ]	
	}
	connection {
   		 host = "${self.public_ip}"
   		 type     = "ssh"
		 user     = "ubuntu"
		 password = ""
	    	 private_key = "${file("${path.module}/terraform-demo")}"
  	}
//	depends_on = [aws_iam_role_policy.test_policy]
}

