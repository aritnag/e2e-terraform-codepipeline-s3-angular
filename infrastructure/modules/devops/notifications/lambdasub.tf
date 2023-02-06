resource "aws_iam_role" "lambda_role" {
  name               = "SNS_TRANSFORM_MESSAGE_LAMBDA_ROLE"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   },
   {
    "Action" : [
        "sns:Publish",
        "sns:Subscribe"
    ],
    "Effect" : "Allow",
    "Resource" : "${aws_sns_topic.e2enotifications.arn}"
}
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/sns-transform.zip"
}

resource "aws_lambda_function" "terraform_lambda_func" {
  filename         = "${path.module}/lambda/sns-transform.zip"
  function_name    = "SNS_Transform_Lambda_Function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = base64sha256("${path.module}/lambda/sns-transform.zip")
  depends_on       = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  environment {
    variables = {
      sns_topic_arn = aws_sns_topic.e2enotifications.arn

    }
  }
}
