locals {
kubernetes_cluster_name = "${var.kubernetes_cluster_name}"
}
provider "aws" {
  region = "eu-west-2"
#  shared_credentials_file = "/opt/mywork/Terraform/.aws/credentials"
  profile                 = "default"
  
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.s3_bucket}" 
 # key    = "dev"
  force_destroy = true
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
}
resource "aws_s3_bucket_object" "folder1" {
    bucket = "${var.s3_bucket}"
    acl    = "private"
    key    = "dev/"
    source = "/dev/null"
}

