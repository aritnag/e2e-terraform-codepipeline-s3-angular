output "codebuild_s3_upload" {
  value = aws_codebuild_project.static_web_build
}
output "codebuild_cache_invalidation" {
  value = aws_codebuild_project.cloudfront_invalidation
}