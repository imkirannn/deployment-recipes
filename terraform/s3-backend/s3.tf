locals {
kubernetes_cluster_name = "${var.kubernetes_cluster_name}"
}
provider "aws" {
  region 	= "eu-west-2"
  profile       = "default"
  
}
resource "aws_s3_bucket" "terraform_state" {
  bucket 	= "${var.s3_bucket}" 
  force_destroy = true
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled 	= true
  }
}
resource "aws_s3_bucket_object" "folder1" {
    bucket = "${aws_s3_bucket.terraform_state.bucket}"
    acl    = "private"
    key    = "dev/"
    source = "/dev/null"
}

