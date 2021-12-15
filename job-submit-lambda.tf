locals {
  submit_lambda_zip_filename         = "${path.module}/submit-lambda.zip"
  submit_lambda_notification_webhook = var.submit-lambda-notification-webhook
  mediaconvert_endpoint              = var.mediaconvert-endpoint
}

resource "aws_lambda_function" "video-conversion-submit" {
  function_name = "${module.label.namespace}-${module.label.stage}-video-conversion-submit"
  tags          = module.label.tags

  filename         = local.submit_lambda_zip_filename
  source_code_hash = data.archive_file.lambda.output_base64sha256

  handler = "index.handler"
  role    = aws_iam_role.video-conversion-submit-lambda-role.arn
  runtime = "nodejs14.x"

  environment {
    variables = {
      "DESTINATION_BUCKET"       = module.video-cdn.s3_bucket
      "JOB_SETTINGS"             = "job-settings.json"
      "MEDIACONVERT_ENDPOINT"    = local.mediaconvert_endpoint
      "MEDIACONVERT_ROLE"        = aws_iam_role.media-convert-execute-role.arn
      "NOTIFICATION_WEBHOOK"     = local.submit_lambda_notification_webhook
      "NOTIFICATION_AUTH_HEADER" = var.notification-webhook-auth-header
    }
  }
}

data "archive_file" "lambda" {
  type             = "zip"
  source_dir       = "${path.module}/job-submit-lambda"
  output_path      = local.submit_lambda_zip_filename
  output_file_mode = "0755"
}

resource "aws_iam_role" "video-conversion-submit-lambda-role" {
  name                = "${module.label.namespace}-${module.label.stage}-video-conversion-submit-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  tags                = module.label.tags
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]

  inline_policy {
    name = "jobSubmitServiceRoleDefaultPolicy"
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
            Resource = "arn:aws:mediaconvert:${var.aws_region}:${var.aws_used_account_no}:*"
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

resource "aws_lambda_permission" "s3_notification" {
  statement_id   = "AllowExecutionS3Notification"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.video-conversion-submit.arn
  principal      = "s3.amazonaws.com"
  source_account = var.aws_used_account_no
  source_arn     = module.video-source.bucket_arn
}
