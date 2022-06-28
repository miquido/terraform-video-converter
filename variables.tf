variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = string
  default     = "app"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "aws_used_account_no" {
  type        = string
  description = "AWS Organization Account number used to assume role on"
}

variable "submit-lambda-notification-webhook" {
  type        = string
  description = "endpoint for notification about errors"
}

variable "complete-lambda-notification-webhook" {
  type        = string
  description = "endpoint for notification about conversion process"
}

variable "notification-webhook-auth-header" {
  type        = string
  default     = ""
  description = "webhook authorization header"
}

variable "mediaconvert-endpoint" {
  type        = string
  description = "your media convert endpoint"
}

variable "cloudfront_price_class" {
  type        = string
  default     = "PriceClass_100"
  description = "Price class for video cloudfront distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100`"
}

variable "dns_alias_enabled" {
  type        = bool
  default     = false
  description = "Create a DNS alias for the CDN. Requires `parent_zone_id` or `parent_zone_name`"
}

variable "dns_alias_name" {
  type        = string
  default     = false
  description = "Create a DNS alias for the CDN"
}

variable "parent_zone_id" {
  type        = string
  default     = ""
  description = "ID of the hosted zone to contain this record (or specify `parent_zone_name`). Requires `dns_alias_enabled` set to true"
}

variable "acm_certificate_arn" {
  type        = string
  description = "Existing ACM Certificate ARN"
  default     = ""
}

variable "uploading_service_role" {
  type        = string
  description = "Role of the service that will upload videos"
  default     = ""
}

variable "trusted_key_group" {
  type        = string
  description = "Optional parameter to set CF trusted_key_groups, used for signed urls on CF"
  default     = ""
}
