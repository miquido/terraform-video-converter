provider "aws" {
  region = "us-east-1"
}

module "video-streaming" {
  source    = "git::ssh://git@gitlab.com/miquido/terraform/terraform-video-converter"
  name      = "video-streaming"
  stage     = "test"
  namespace = "test"

  aws_region          = "us-east-1"
  aws_used_account_no = "134446265017"

  mediaconvert-endpoint                = "https://yk2lhke4b.mediaconvert.eu-central-1.amazonaws.com"
  submit-lambda-notification-webhook   = "https://cf74a368e3b9e2b4c8fbcfeee8770dde.m.pipedream.net"
  complete-lambda-notification-webhook = "https://cf74a368e3b9e2b4c8fbcfeee8770dde.m.pipedream.net"
}