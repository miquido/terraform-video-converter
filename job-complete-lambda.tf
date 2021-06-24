locals {
  complete_lambda_function_name        = "video-conversion-complete"
  complete_lambda_zip_filename         = "${path.module}/complete-lambda.zip"
  complete_lambda_notification_webhook = var.complete-lambda-notification-webhook
}

resource "aws_lambda_function" "video-conversion-complete" {
  function_name = local.complete_lambda_function_name
  tags          = module.label.tags

  filename         = local.complete_lambda_zip_filename
  source_code_hash = data.archive_file.complete-lambda-archive.output_base64sha256

  handler = "index.handler"
  role    = aws_iam_role.video-conversion-complete-lambda-role.arn
  runtime = "nodejs14.x"

  environment {
    variables = {
      "MEDIACONVERT_ENDPOINT" = local.mediaconvert_endpoint
      "CLOUDFRONT_DOMAIN"     = module.video-cdn.cf_domain_name
      "NOTIFICATION_WEBHOOK"  = local.complete_lambda_notification_webhook
    }
  }
}

data "archive_file" "complete-lambda-archive" {
  type        = "zip"
  source_dir  = "${path.module}/job-complete-lambda"
  output_path = local.complete_lambda_zip_filename
}

resource "aws_iam_role" "video-conversion-complete-lambda-role" {
  name                = local.complete_lambda_function_name
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  tags                = module.label.tags
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  inline_policy {
    name = "jobcompleteServiceRoleDefaultPolicyEC39C00E"
    policy = jsonencode(
      {
        Statement = [
          {
            Action   = "mediaconvert:GetJob"
            Effect   = "Allow"
            Resource = var.mediaconvert-arn
          },
        ]
        Version = "2012-10-17"
      }
    )
  }
}

resource "aws_cloudwatch_event_rule" "complete_lambda_event_rule" {
  name        = "complete_lambda_event_rule"
  description = "complete_lambda_event_rule"
  tags        = module.label.tags

  event_pattern = jsonencode(
    {
      detail = {
        status = [
          "COMPLETE",
          "ERROR",
          "CANCELED",
          "INPUT_INFORMATION",
        ]
      }
      source = [
        "aws.mediaconvert",
      ]
    }
  )
}

resource "aws_cloudwatch_event_target" "default" {
  target_id = local.complete_lambda_function_name
  rule      = aws_cloudwatch_event_rule.complete_lambda_event_rule.name
  arn       = aws_lambda_function.video-conversion-complete.arn
}
