provider "aws" {}


variable "env" {}
variable "staticwebsite" {}
variable "distributionid" {}
variable "repository_name" {}
variable "repository_branch" {}
variable "codepipeline_bucket" {}

variable "notifications" {}





data "aws_codecommit_repository" "code_commit_repo" {
  repository_name = var.repository_name
}

data "aws_s3_bucket" "staticwebsite_bucket" {
  bucket = var.staticwebsite
}

data "aws_cloudfront_distribution" "staticwebsite" {
  id = var.distributionid
}



