locals {
  submit_lambda_function_name        = "video-conversion-submit"
  submit_lambda_zip_filename         = "${path.module}/submit-lambda.zip"
  submit_lambda_notification_webhook = var.submit-lambda-notification-webhook
  mediaconvert_endpoint              = var.mediaconvert-endpoint
}

resource "aws_lambda_function" "video-conversion-submit" {
  function_name = local.submit_lambda_function_name
  tags          = module.label.tags

  filename         = local.submit_lambda_zip_filename
  source_code_hash = data.archive_file.lambda.output_base64sha256

  handler = "index.handler"
  role    = aws_iam_role.video-conversion-submit-lambda-role.arn
  runtime = "nodejs14.x"

  environment {
    variables = {
      "DESTINATION_BUCKET"    = module.video-cdn.s3_bucket
      "JOB_SETTINGS"          = "job-settings.json"
      "MEDIACONVERT_ENDPOINT" = local.mediaconvert_endpoint
      "MEDIACONVERT_ROLE"     = aws_iam_role.media-convert-execute-role.arn
      "NOTIFICATION_WEBHOOK"  = local.submit_lambda_notification_webhook
    }
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/job-submit-lambda"
  output_path = local.submit_lambda_zip_filename
}

resource "aws_iam_role" "video-conversion-submit-lambda-role" {
  name                = local.submit_lambda_function_name
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  tags                = module.label.tags
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  inline_policy {
    name = "jobSubmitServiceRoleDefaultPolicyEC39C00E"
    policy = jsonencode(
      {
        Statement = [
          {
            Action   = "iam:PassRole"
            Effect   = "Allow"
            Resource = aws_iam_role.media-convert-execute-role.arn
          },
          {
            Action   = "mediaconvert:CreateJob"
            Effect   = "Allow"
            Resource = var.mediaconvert-arn
          },
          {
            Action = "s3:GetObject"
            Effect = "Allow"
            Resource = [
              module.video-source.bucket_arn,
              "${module.video-source.bucket_arn}/*",
            ]
          },
        ]
        Version = "2012-10-17"
      }
    )
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}