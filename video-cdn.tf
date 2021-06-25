module "video-cdn" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn.git?ref=tags/0.72.0"

  name                    = "video"
  namespace               = module.label.namespace
  stage                   = module.label.stage
  tags                    = module.label.tags
  extra_origin_attributes = [""]

  dns_alias_enabled = false
  //  dns_alias_enabled        = true
  //  parent_zone_id           = aws_route53_zone.primary.zone_id
  //  acm_certificate_arn = module.acm_cdn.arn

  allowed_methods        = ["GET", "HEAD"]
  encryption_enabled     = true
  price_class            = "PriceClass_100"
  viewer_protocol_policy = "redirect-to-https"
  origin_force_destroy   = true
  compress               = true
  website_enabled        = false
  forward_query_string   = true
  forward_cookies        = "none"
  min_ttl                = "604800" //7 days
  default_ttl            = "604800" //7 days
  forward_header_values  = []
}

