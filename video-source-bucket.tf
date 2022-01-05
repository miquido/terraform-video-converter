module "video-source" {
  name      = "video-source"
  stage     = module.label.stage
  namespace = module.label.namespace
  tags      = module.label.tags

  source             = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=0.44.2"
  enabled            = true
  user_enabled       = false
  versioning_enabled = true
  acl                = "private"
  sse_algorithm      = "AES256"
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
