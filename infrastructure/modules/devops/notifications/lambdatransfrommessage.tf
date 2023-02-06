

resource "aws_sns_topic" "lambdatransfrommessage" {
  name = "lambdatransfrommessage"
}
resource "aws_sns_topic_subscription" "lambdatransfrommessage_subscription" {
  topic_arn = aws_sns_topic.lambdatransfrommessage.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.terraform_lambda_func.arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_lambda_func.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.lambdatransfrommessage.arn
}


