<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![Miquido][logo]](https://www.miquido.com/)

# terraform-video-converter
A solution that will generate adaptive streaming urls for videos uploaded to video-source bucket.
After conversion, videos will be available under
module.video-cdn.cf_domain_name/file_name/protocol/file_name.protocol_extension
ex. https://playground-test-video.s3.eu-central-1.amazonaws.com/IMG_6326.mov/AppleHLS1/IMG_6326.m3u8
Also there will be notifications send on endpoint under vars submit-lambda-notification-webhook and
complete-lambda-notification-webhook.

By default the solution will make 3 types of conversion: HLS, DASHIS and mp4. This can be changed by
modifiying video-source/converter-config-1/job-settings.json file.

Files should be uploaded to video-source/converter-config-1 and only .mp4, .mpg, .m4v, .mov, .m2ts
are supported (case sensitive)


Most useful fields from 'Complete lambda' notification will be probably:
```
event.detail.userMetadata.guid,
event.detail.userMetadata.filename,
event.detail.status,
```
<b>Important</b><br>
The solution assumes that a video file will be uploaded into `...video-source` bucket with a path format:<br>
`config-name/guid/.../filename`<br>
Where `guid` in the path is `guid` in the notification. For example:<br>
`myVideoConfig/user1/video2` or <br>
`converter-config-1/7269c6d9-7884-4458-9f70-f142f6879a18/feed/video/28cc892d-0118-4c4c-957e-78aa39462e92`<br>
---
**Terraform Module**
## Usage

```hcl
module "adaptive-video" {
  source    = "git::ssh://git@gitlab.com/miquido/terraform/terraform-video-converter.git?ref=tags/..."
  name      = "adaptive-video"
  stage     = var.environment
  namespace = var.project

  aws_region          = var.aws_region
  aws_used_account_no = var.aws_used_account_no

  dns_alias_enabled   = true
  dns_alias_name      = local.videos_domain
  parent_zone_id      = aws_route53_zone.primary.zone_id
  acm_certificate_arn = local.cdn_acm_certificate_arn

  // ECS task that uploads videos
  uploading_service_role = module.ecs-alb-task-main-api.task_role_name

  // unique endpoint from your account
  mediaconvert-endpoint                = "https://xxxxxxxx.mediaconvert.us-east-1.amazonaws.com"
  // sends error when can't create conversion job
  submit-lambda-notification-webhook    = "https://${local.main_api_domain}/submit"
  // sends completed job details or error object
  complete-lambda-notification-webhook  = "https://${local.main_api_domain}/complete"
  notification-webhook-auth-header     = "Api-Key ${data.aws_ssm_parameter.main-api_JOBS_API_KEY.value}"
}
```
<!-- markdownlint-disable -->
## Makefile Targets
```text
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```
<!-- markdownlint-restore -->
<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.41 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.41 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_label"></a> [label](#module\_label) | git::https://github.com/cloudposse/terraform-terraform-label.git | 0.8.0 |
| <a name="module_video-cdn"></a> [video-cdn](#module\_video-cdn) | git::https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn.git | 0.82.3 |
| <a name="module_video-source"></a> [video-source](#module\_video-source) | git::https://github.com/cloudposse/terraform-aws-s3-bucket.git | 0.47.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.complete_lambda_event_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.video-s3-iam-policy-user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.media-convert-execute-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.video-conversion-complete-lambda-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.video-conversion-submit-lambda-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.video-iam-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.video-conversion-complete](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.video-conversion-submit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_cloudwatch_to_invoke_video_complete](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.s3_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_notification.new_video](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_object.converter-config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) | resource |
| [aws_s3_bucket_public_access_block.video-cdn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.video-source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [archive_file.complete-lambda-archive](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.media-convert-execute-assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.video-s3-iam-policy-user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | Existing ACM Certificate ARN | `string` | `""` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_aws_used_account_no"></a> [aws\_used\_account\_no](#input\_aws\_used\_account\_no) | AWS Organization Account number used to assume role on | `string` | n/a | yes |
| <a name="input_cloudfront_price_class"></a> [cloudfront\_price\_class](#input\_cloudfront\_price\_class) | Price class for video cloudfront distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100` | `string` | `"PriceClass_100"` | no |
| <a name="input_complete-lambda-notification-webhook"></a> [complete-lambda-notification-webhook](#input\_complete-lambda-notification-webhook) | endpoint for notification about conversion process | `string` | n/a | yes |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| <a name="input_dns_alias_enabled"></a> [dns\_alias\_enabled](#input\_dns\_alias\_enabled) | Create a DNS alias for the CDN. Requires `parent_zone_id` or `parent_zone_name` | `bool` | `false` | no |
| <a name="input_dns_alias_name"></a> [dns\_alias\_name](#input\_dns\_alias\_name) | Create a DNS alias for the CDN | `string` | `false` | no |
| <a name="input_mediaconvert-endpoint"></a> [mediaconvert-endpoint](#input\_mediaconvert-endpoint) | your media convert endpoint | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'cluster' | `string` | `"app"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| <a name="input_notification-webhook-auth-header"></a> [notification-webhook-auth-header](#input\_notification-webhook-auth-header) | webhook authorization header | `string` | `""` | no |
| <a name="input_parent_zone_id"></a> [parent\_zone\_id](#input\_parent\_zone\_id) | ID of the hosted zone to contain this record (or specify `parent_zone_name`). Requires `dns_alias_enabled` set to true | `string` | `""` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | n/a | yes |
| <a name="input_submit-lambda-notification-webhook"></a> [submit-lambda-notification-webhook](#input\_submit-lambda-notification-webhook) | endpoint for notification about errors | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_uploading_service_role"></a> [uploading\_service\_role](#input\_uploading\_service\_role) | Role of the service that will upload videos | `string` | `""` | no |

## Outputs

No outputs.
<!-- markdownlint-restore -->


## Developing

1. Make changes in terraform files

2. Regenerate documentation

    ```bash
    bash <(git archive --remote=git@gitlab.com:miquido/terraform/terraform-readme-update.git master update.sh | tar -xO)
    ```

3. Run lint

    ```
    make lint
    ```

## Copyright

Copyright © 2017-2022 [Miquido](https://miquido.com)




  [logo]: https://www.miquido.com/img/logos/logo__miquido.svg
  [website]: https://www.miquido.com/
  [gitlab]: https://gitlab.com/miquido
  [github]: https://github.com/miquido
  [bitbucket]: https://bitbucket.org/miquido

