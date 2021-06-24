provider "aws" {
  region = "us-east-1"
}

module "video-streaming" {
  source              = "git::ssh://git@gitlab.com/miquido/terraform/terraform-video-converter"
  name                = "video-streaming"
  stage               = test
  namespace           = test
  tags                = test

  execute-api-arn                       = "arn:aws:execute-api:us-east-1:134446265017:*"
  mediaconvert-arn                      = "arn:aws:mediaconvert:us-east-1:134446265017:*"
  submit-lambda-notification-webhook    = "https://cf74a368e3b9e2b4c8fbcfeee8770dde.m.pipedream.net"
  complete-lambda-notification-webhook  = "https://cf74a368e3b9e2b4c8fbcfeee8770dde.m.pipedream.net"
}