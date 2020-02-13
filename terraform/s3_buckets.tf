// S3 bucket to store kops state.
resource "aws_s3_bucket" "kops_state" {
  bucket        = local.kops_state_bucket_name
  acl           = "private"
  force_destroy = true
  tags          = merge(local.tags)
  region	= "eu-west-2"
}
//resource "aws_route53_zone" "private" {
//  name = local.kubernetes_cluster_name

//  vpc {
//    vpc_id = module.dev_vpc.vpc_id
//  }

//}

/* resource "aws_route53_zone" "main" {
  name = local.kubernetes_cluster_name
} */

//resource "aws_route53_zone" "dev" {
//  name = local.kubernetes_cluster_name

 // tags = {
  //  Environment = "dev"
 // }
//}

//resource "aws_route53_record" "dev-ns" {
//  zone_id = "${aws_route53_zone.main.zone_id}"
//  name    = local.kubernetes_cluster_name
//  type    = "NS"
//  ttl     = "30"

//  records = [
//    "${aws_route53_zone.main.name_servers.0}",
//    "${aws_route53_zone.main.name_servers.1}",
//    "${aws_route53_zone.main.name_servers.2}",
//    "${aws_route53_zone.main.name_servers.3}",
//  ]
//}
