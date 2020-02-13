resource "aws_route53_zone" "example" {
  name = local.kubernetes_cluster_name
}

resource "aws_route53_record" "example" {
  allow_overwrite = true
  name            = local.kubernetes_cluster_name
  ttl             = 30
  type            = "NS"
  zone_id         = "${aws_route53_zone.example.zone_id}"

  records = [
    /* "${aws_route53_zone.example.name_servers.0}",
    "${aws_route53_zone.example.name_servers.1}",
    "${aws_route53_zone.example.name_servers.2}",
    "${aws_route53_zone.example.name_servers.3}",
    */
    "ns-1529.awsdns-63.org",
	"ns-1844.awsdns-38.co.uk",
	"ns-251.awsdns-31.com",
	"ns-617.awsdns-13.net",
  ]
}
