provider "aws" {}


variable "s3_bucket_id" {}


locals {
  s3_origin_id = "s3_origin_id"
}

resource "aws_cloudfront_origin_access_identity" "frontend_distribution_oai" {
  comment = "my s3 oai identity"
}
resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = var.s3_bucket_id.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_distribution_oai.cloudfront_access_identity_path
    }
  }
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloudfront"
  default_root_object = "index.html"




  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }


  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "SE"]
    }
  }

  tags = {
    Environment = "production"
  }



  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

