locals {
  video_source_bucked_name = "video-source"
}

module "video-source" {
  name      = local.video_source_bucked_name
  stage     = module.label.stage
  namespace = module.label.namespace
  tags      = module.label.tags

  source                  = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=4.0.0"
  enabled                 = true
  user_enabled            = false
  versioning_enabled      = true
  acl                     = "private"
  sse_algorithm           = "AES256"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "converter-config" {
  bucket                 = module.video-source.bucket_id
  for_each               = fileset("${path.module}/video-source-bucket/", "**")
  key                    = each.value
  source                 = "${path.module}/video-source-bucket/${each.value}"
  etag                   = filemd5("${path.module}/video-source-bucket/${each.value}")
  acl                    = "private"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_notification" "new_video" {
  bucket = module.video-source.bucket_id

  lambda_function {
    id                  = "new_file"
    lambda_function_arn = aws_lambda_function.video-conversion-submit.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }
}

data "aws_iam_policy_document" "video-s3-iam-policy-user" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketLocation",
      "s3:AbortMultipartUpload",
    ]

    resources = [
      "arn:aws:s3:::${local.video_source_bucked_name}/*",
      "arn:aws:s3:::${local.video_source_bucked_name}",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "video-iam-policy" {
  role       = var.uploading_service_role
  policy_arn = aws_iam_policy.video-s3-iam-policy-user.arn
}

resource "aws_iam_policy" "video-s3-iam-policy-user" {
  name   = "S3-Video-Access"
  path   = "/"
  policy = data.aws_iam_policy_document.video-s3-iam-policy-user.json
}
