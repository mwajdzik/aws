provider "aws" {
  version = "~> 3.0"
  region  = "us-west-2"
  profile = "default"
}

data "aws_caller_identity" "current" {
}

# ---

resource "aws_sqs_queue" "product_visits_data_queue" {
  name = "product_visits_data_queue"

  delay_seconds             = 5
  receive_wait_time_seconds = 10
  max_message_size          = 2048
  message_retention_seconds = 86400

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_dead_letter.arn
    maxReceiveCount     = 4
  })
}

resource "aws_sqs_queue" "queue_dead_letter" {
  name = "queue_dead_letter"
}

# ---

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

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

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "AWS IAM Policy for managing AWS lambda role"
  path        = "/"
  policy      = templatefile("templates/iam_policy_for_lambdas.json", {
    dynamodb_table = aws_dynamodb_table.product_visits_dynamodb_table.arn
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# ---

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/"
  output_path = "${path.module}/lambdas/application.zip"
}

resource "aws_lambda_function" "product_visits_lambda" {
  function_name = "product_visits_lambda"
  filename      = "${path.module}/lambdas/application.zip"
  handler       = "product_visits_lambda.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_role.arn
}

# ---

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.product_visits_data_queue.arn
  function_name    = aws_lambda_function.product_visits_lambda.arn
  enabled          = true
  batch_size       = 1
}

# ---

resource "aws_dynamodb_table" "product_visits_dynamodb_table" {
  name           = "ProductVisits"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "ProductVisitKey"

  attribute {
    name = "ProductVisitKey"
    type = "S"
  }
}
