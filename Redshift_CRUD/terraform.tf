provider "aws" {
  region = "us-east-1" 
}

# Define variables
variable "redshift_workgroup" {
  description = "The Redshift workgroup"
}

variable "redshift_database" {
  description = "The Redshift database"
}

variable "redshift_secret_arn" {
  description = "The ARN of the Redshift secret"
}


variable "confluent_bootstrap" {
  description = "Confluent bootstrap"
}

variable "confluent_topic" {
  description = "Confluent topic"
}


variable "confluent_secret" {
  description = "Confluent secret arn"
}


resource "aws_lambda_function" "redshift_upsert_function" {
  function_name = "redshift-upsert-function"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  filename      = "redshift_upsert_lambda.zip"
  role       = aws_iam_role.lambda_execution_role.arn
  timeout = 60
  environment {
    variables = {
      REDSHIFT_WORKGROUP = var.redshift_workgroup,
      REDSHIFT_DATABASE  = var.redshift_database,
      REDSHIFT_SECRET_ARN = var.redshift_secret_arn,
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "redshift_upsert_lambda_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "lambda_policy" {
  name = "test_policy"
  role = aws_iam_role.lambda_execution_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "redshift-data:ExecuteStatement",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "secretsmanager:GetSecretValue",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_lambda_event_source_mapping" "confluent_trigger" {
  function_name     = aws_lambda_function.redshift_upsert_function.arn
  topics            = [var.confluent_topic]
  starting_position = "TRIM_HORIZON"

  self_managed_event_source {
    endpoints = {
      KAFKA_BOOTSTRAP_SERVERS = var.confluent_bootstrap
    }
  }
  source_access_configuration {
    type = "BASIC_AUTH"
    uri  = var.confluent_secret
  }
}
