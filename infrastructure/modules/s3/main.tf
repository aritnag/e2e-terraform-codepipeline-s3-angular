provider "aws" {}


variable "s3_deployment_bucket" {}

locals {
  mime_type_mappings = jsondecode(file("${path.module}/mime.json"))
}
data "external" "frontend_build" {
  program = ["bash", "-c", <<EOT
(npm ci && npm run build ) >&2 && echo "{\"dest\": \"dist\"}"
EOT
  ]
  working_dir = "${path.module}/../../../application"
}

data "aws_s3_bucket" "frontend_s3_upload_bucket" {
  bucket = var.s3_deployment_bucket

}
resource "aws_s3_bucket_cors_configuration" "cors_configuration" {
  bucket = data.aws_s3_bucket.frontend_s3_upload_bucket.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "frontend_bucket" {
  bucket = data.aws_s3_bucket.frontend_s3_upload_bucket.bucket
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_object" "frontend_object" {
  for_each     = fileset("${data.external.frontend_build.working_dir}/${data.external.frontend_build.result.dest}", "*")
  key          = each.value
  source       = "${data.external.frontend_build.working_dir}/${data.external.frontend_build.result.dest}/${each.value}"
  bucket       = data.aws_s3_bucket.frontend_s3_upload_bucket.bucket
  etag         = filemd5("${data.external.frontend_build.working_dir}/${data.external.frontend_build.result.dest}/${each.value}")
  content_type = lookup(local.mime_type_mappings, regex("\\.[^.]+$", each.value), null)
}


