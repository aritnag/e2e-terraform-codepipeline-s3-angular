output "notification" {
  value = aws_sns_topic.e2enotifications
}

output "lambdanotifications" {
  value = aws_sns_topic.lambdatransfrommessage
}