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

variable "execute-api-arn" {
  type        = string
  description = "arn:aws:execute-api:var.aws_region:var.aws_used_account_no:*"
}

variable "mediaconvert-arn" {
  type        = string
  description = "arn:aws:mediaconvert:var.aws_region:var.aws_used_account_no:*"
}

variable "submit-lambda-notification-webhook" {
  type        = string
  description = "endpoint for notification about errors"
}

variable "complete-lambda-notification-webhook" {
  type        = string
  description = "endpoint for notification about conversion process"
}

variable "mediaconvert-endpoint" {
  type        = string
  description = "your media convert endpoint"
}