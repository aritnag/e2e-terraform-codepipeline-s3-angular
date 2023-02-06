


data "template_file" "buildspec_cacheinvalidation" {
  template = file("${path.module}/invalidate/buildspec.yml")
  vars = {
    env            = var.env
    staticwebsite  = var.staticwebsite
    distributionid = var.distributionid
  }
}

resource "aws_iam_role" "static_build_role_cacheinvalidation" {
  name = "static_build_role_cacheinvalidation"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}



resource "aws_iam_role_policy" "static_build_role_cacheinvalidation_policy" {
  name = "static_build_role_cacheinvalidation_policy"
  role = aws_iam_role.static_build_role_cacheinvalidation.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    },
        {
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${data.aws_s3_bucket.staticwebsite_bucket.arn}",
        "${data.aws_s3_bucket.staticwebsite_bucket.arn}/*",
         "${var.codepipeline_bucket.arn}",
        "${var.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect":"Allow",
      "Action": [
        "cloudfront:CreateInvalidation"
      ],
      "Resource": [
        "${data.aws_cloudfront_distribution.staticwebsite.arn}"
      ]
    }
  ]
}
EOF
}
resource "aws_codebuild_project" "cloudfront_invalidation" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "cloudfront_invalidation"
  queued_timeout = 480
  service_role   = aws_iam_role.static_build_role_cacheinvalidation.arn
  tags = {
    Environment = var.env
  }

  artifacts {
    encryption_disabled    = false
    name                   = "static-web-build-${var.env}"
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = data.template_file.buildspec_cacheinvalidation.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}



