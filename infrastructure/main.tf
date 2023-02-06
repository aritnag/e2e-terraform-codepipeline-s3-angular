
module "s3_application_deployment" {
  source = "./modules/s3"
  providers = {
    aws = aws
  }
  s3_deployment_bucket = var.s3_deployment_bucket
}

module "cloudfront_distribution" {
  source = "./modules/cloudfront"
  providers = {
    aws = aws
  }
  s3_bucket_id = module.s3_application_deployment.frontend_s3_upload_bucket
}

module "iam_definations" {
  source = "./modules/iam"
  providers = {
    aws = aws
  }
  s3_bucket_id                          = module.s3_application_deployment.frontend_s3_upload_bucket
  aws_cloudfront_origin_access_identity = module.cloudfront_distribution.cloudfront_origin_access_identity
}







module "codecommit" {
  source = "./modules/devops/codecommit"
  providers = {
    aws = aws
  }
  repository_name = var.repository_name

}

module "codebuild" {
  source = "./modules/devops/codebuild/"
  providers = {
    aws = aws
  }
  env                 = var.env
  repository_name     = var.repository_name
  repository_branch   = var.repository_branch
  staticwebsite       = module.s3_application_deployment.frontend_s3_upload_bucket.id
  distributionid      = module.cloudfront_distribution.cloudfront_distribution_details.id
  codepipeline_bucket = module.codepipeline.codepipeline_bucket
  notifications       = module.notifications.notification
}


module "notifications" {
  source = "./modules/devops/notifications"
  providers = {
    aws = aws
  }
  emails = var.emails
}

module "codepipeline" {
  source = "./modules/devops/codepipeline"
  providers = {
    aws = aws
  }
  env                          = var.env
  repository_name              = var.repository_name
  repository_branch            = var.repository_branch
  staticwebsite                = module.s3_application_deployment.frontend_s3_upload_bucket.id
  distributionid               = module.cloudfront_distribution.cloudfront_distribution_details.id
  codebuild_s3_upload          = module.codebuild.codebuild_s3_upload
  codepipeline_bucket          = var.artifacts_bucket_name
  codebuild_cache_invalidation = module.codebuild.codebuild_cache_invalidation
  lambdanotifications          = module.notifications.lambdanotifications
}