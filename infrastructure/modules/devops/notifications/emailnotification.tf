provider "aws" {}

variable "emails" {}
locals {
  emails = [var.emails]
}
resource "aws_sns_topic" "e2enotifications" {
  name = "notification"
}
resource "aws_sns_topic_subscription" "topic_email_subscription" {
  count     = length(local.emails)
  topic_arn = aws_sns_topic.e2enotifications.arn
  protocol  = "email"
  endpoint  = local.emails[count.index]
}


