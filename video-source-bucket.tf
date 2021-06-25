module "video-source" {
  name      = "video-source"
  stage     = module.label.stage
  namespace = module.label.namespace
  tags      = module.label.tags

  source             = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=tags/0.38.0"
  enabled            = true
  user_enabled       = false
  versioning_enabled = true
  acl                = "private"
  sse_algorithm      = "AES256"
}

resource "aws_s3_bucket_object" "converter-config" {
  bucket                 = module.video-source.bucket_id
  for_each               = fileset("video-source-bucket/", "**")
  key                    = each.value
  source                 = "video-source-bucket/${each.value}"
  etag                   = filemd5("video-source-bucket/${each.value}")
  acl                    = "private"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_notification" "new_video" {
  bucket = module.video-source.bucket_id

  lambda_function {
    id                  = "new_mp4_video"
    lambda_function_arn = aws_lambda_function.video-conversion-submit.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".mp4"
  }

  lambda_function {
    id                  = "new_mpg_video"
    lambda_function_arn = aws_lambda_function.video-conversion-submit.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".mpg"
  }

  lambda_function {
    id                  = "new_m4v_video"
    lambda_function_arn = aws_lambda_function.video-conversion-submit.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".m4v"
  }

  lambda_function {
    id                  = "new_mov_video"
    lambda_function_arn = aws_lambda_function.video-conversion-submit.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".mov"
  }

  lambda_function {
    id                  = "new_m2ts_video"
    lambda_function_arn = aws_lambda_function.video-conversion-submit.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".m2ts"
  }
}
