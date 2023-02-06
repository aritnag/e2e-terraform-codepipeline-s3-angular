output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.frontend_distribution.domain_name
}
output "cloudfront_origin_access_identity" {
  value = aws_cloudfront_origin_access_identity.frontend_distribution_oai
}

output "cloudfront_distribution_details" {
  value = aws_cloudfront_distribution.frontend_distribution
}

