variable "profile" {
  type    = string
  default = "default"
}


variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "env" {
  description = "Deployment environment"
  default     = "dev"
}

variable "repository_branch" {
  description = "Repository branch to connect to"
  default     = "master"
}



variable "repository_name" {
  description = "CodeCommit repository name"
  default     = "repository_name"
}

variable "s3_deployment_bucket" {
  description = "S3 Bucket to host the Website"
  default     = "s3_deployment_bucket"
}

variable "artifacts_bucket_name" {
  description = "S3 Bucket for storing artifacts"
  default     = "artifacts_bucket_name"
}

variable "emails" {
  description = "Comma Seperated Emails for Sending Notifications"
  default     = "emailaddress"
}
