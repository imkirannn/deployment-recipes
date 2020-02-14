//output "iam_role" {
// value = "${aws_iam_role.test_role.id}"
//}
output "instance_ips" {
  value = ["${aws_instance.web.*.public_ip}"]
}

