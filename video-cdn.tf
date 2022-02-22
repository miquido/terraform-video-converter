module "video-cdn" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn.git?ref=0.82.3"

  name                    = "video"
  namespace               = module.label.namespace
  stage                   = module.label.stage
  tags                    = module.label.tags
  extra_origin_attributes = [""]

  aliases             = [var.dns_alias_name]
  dns_alias_enabled   = var.dns_alias_enabled
  parent_zone_id      = var.parent_zone_id
  acm_certificate_arn = var.acm_certificate_arn

  allowed_methods        = ["GET", "HEAD"]
  encryption_enabled     = true
  price_class            = var.cloudfront_price_class
  viewer_protocol_policy = "redirect-to-https"
  origin_force_destroy   = true
  compress               = true
  website_enabled        = false
  forward_query_string   = false
  forward_cookies        = "none"
  min_ttl                = "604800" //7 days
  default_ttl            = "604800" //7 days
  forward_header_values  = []
}

resource "aws_s3_bucket_public_access_block" "video-cdn" {
  bucket                  = module.video-cdn
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
