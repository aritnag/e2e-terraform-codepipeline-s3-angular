
provider "aws" {}

variable "s3_bucket_id" {}
variable "aws_cloudfront_origin_access_identity" {}


data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.s3_bucket_id.arn}/*", "${var.s3_bucket_id.arn}"]

    principals {
      type        = "AWS"
      identifiers = [var.aws_cloudfront_origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_website_hosting" {
  bucket = var.s3_bucket_id.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "frontend_s3_upload_bucket_block" {
  bucket = var.s3_bucket_id.id

  block_public_acls   = true
  block_public_policy = true
}
