resource "aws_ecr_repository" "repository" {
  name = local.repository_name
}
