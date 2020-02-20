locals {
kubernetes_cluster_name = "k8s-dev.cloudhands.online"
}
provider "aws" {
  region = "eu-west-2"
  shared_credentials_file = "/opt/mywork/Terraform/.aws/credentials"
  profile                 = "default"
  
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = tf-state-kops-blog
 # key    = "dev"
  force_destroy = true
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
}
resource "aws_s3_bucket_object" "folder1" {
    bucket = tf-state-kops-blog
    acl    = "private"
    key    = "dev/"
    source = "/dev/null"
}

