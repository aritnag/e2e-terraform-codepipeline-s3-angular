





data "template_file" "buildspec_s3upload" {
  template = file("${path.module}/s3upload/buildspec.yml")
  vars = {
    env            = var.env
    staticwebsite  = var.staticwebsite
    distributionid = var.distributionid
  }
}

resource "aws_iam_role" "static_build_role_s3upload" {
  name = "static_build_role_s3upload"
  lifecycle {
    create_before_destroy = true
  }
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



resource "aws_iam_role_policy" "static_build_role_s3upload_policy" {
  name = "static_build_role_s3upload_policy"
  role = aws_iam_role.static_build_role_s3upload.id

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
resource "aws_codebuild_project" "static_web_build" {
  badge_enabled  = false
  build_timeout  = 60
  name           = "static-web-build"
  queued_timeout = 480
  service_role   = aws_iam_role.static_build_role_s3upload.arn
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
    buildspec           = data.template_file.buildspec_s3upload.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }
}



