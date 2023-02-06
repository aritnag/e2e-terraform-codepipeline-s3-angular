
provider "aws" {}

variable "env" {}
variable "staticwebsite" {}
variable "distributionid" {}
variable "repository_name" {}
variable "repository_branch" {}
variable "codebuild_s3_upload" {}
variable "codebuild_cache_invalidation" {}
variable "codepipeline_bucket" {}
variable "lambdanotifications" {}


data "aws_codecommit_repository" "code_commit_repo" {
  repository_name = var.repository_name
}

data "aws_s3_bucket" "staticwebsite_bucket" {
  bucket = var.staticwebsite
}

data "aws_cloudfront_distribution" "staticwebsite_distribution_details" {
  id = var.distributionid
}


resource "aws_s3_bucket" "codepipeline_bucket" {
  #bucket = "tf-s3-angular-e2e-devops"
  bucket        = var.codepipeline_bucket
  force_destroy = true
}

resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}



resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName       = var.repository_name
        BranchName           = var.repository_branch
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName   = var.codebuild_s3_upload.name
        PrimarySource = "Source"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output_cached"]
      version          = "1"


      configuration = {
        ProjectName   = var.codebuild_cache_invalidation.name
        PrimarySource = "Source"
      }
    }
  }
}






resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*",
        "${data.aws_s3_bucket.staticwebsite_bucket.arn}",
        "${data.aws_s3_bucket.staticwebsite_bucket.arn}/*"

      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:*"
      ],
      "Resource": "${data.aws_codecommit_repository.code_commit_repo.arn}"
    }
  ]
}
EOF
}

