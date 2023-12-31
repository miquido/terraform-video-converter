module "label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=0.8.0"
  namespace  = var.namespace
  name       = var.name
  stage      = var.stage
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
  enabled    = "true"
}

resource "aws_iam_role" "media-convert-execute-role" {
  name               = "${module.label.namespace}-${module.label.stage}-media-convert-execute-role"
  assume_role_policy = data.aws_iam_policy_document.media-convert-execute-assume_role.json
  tags               = module.label.tags

  inline_policy {
    name = "media-convert-execute-role"
    policy = jsonencode(
      {
        Statement = [
          {
            Action = [
              "s3:GetObject",
              "s3:PutObject",
            ]
            Effect = "Allow"
            Resource = [
              "${module.video-source.bucket_arn}/*",
              "${module.video-cdn.s3_bucket_arn}/*",
            ]
          },
          {
            Action   = "execute-api:Invoke"
            Effect   = "Allow"
            Resource = "arn:aws:execute-api:${var.aws_region}:${var.aws_used_account_no}:*"
          },
        ]
        Version = "2012-10-17"
      }
    )
  }

}

data "aws_iam_policy_document" "media-convert-execute-assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["mediaconvert.amazonaws.com"]
    }
  }
}
