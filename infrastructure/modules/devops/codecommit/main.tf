
provider "aws" {}

variable "repository_name" {}
data "aws_codecommit_repository" "code_commit_repo" {
  repository_name = var.repository_name
}

