###Terraform config

terraform {
  backend "s3" {
    bucket = "stuterraformstate" // S3 bucket required before init, or use a 'local' backend
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }

  provider "aws" {
    region = "eu-west-1"
  }
}

provider "aws" {
  // us-east-1 instance alias for creation of the cf cert
  region = "us-east-1"
  alias  = "use1"
}

##--------------s3
module "s3-www" {
  source     = "../modules/s3-www"
  envName    = "${upper(var.commonTags["environment"])}"
  bucketName = "${var.www_domain_name}"
  commonTags = "${var.commonTags}"
}

##--------------/s3

##--------------cloudfront
module "cloudfront" {
  source           = "../modules/cloudfront"
  acmCertificate   = "${aws_acm_certificate.certificate.arn}"
  www_domain_name  = "${var.www_domain_name}"
  website_endpoint = "${module.s3-www.website_endpoint}"
}

##--------------/cloudfront

##--------------route53
module "r53" {
  source                = "../modules/r53"
  root_domain_name      = "${var.root_domain_name}"
  www_domain_name       = "${var.www_domain_name}"
  r53AliasForDomainName = "${module.cloudfront.domainName}"
  r53AliasForHostedZone = "${module.cloudfront.zoneId}"
}

##--------------/route53

##--------------cert manager
resource "aws_acm_certificate" "certificate" {
  domain_name               = "*.${var.root_domain_name}" //ensure that domain is verified ownership before apply or the cf distro will fail
  provider                  = "aws.use1"
  validation_method         = "${var.validation_method}"
  subject_alternative_names = ["${var.root_domain_name}"]
}

##--------------/cert manager

##--------------cloudwatch metric alerts for cloudfront
module "cfCloudwatch" {
  source                 = "../modules/cloudwatchAlarm"
  alarmActionsEnabled    = "true"
  topicArn               = "${aws_sns_topic.dev-sns.arn}"
  cloudfrontDistribution = "${module.cloudfront.cfDistributionId}"
  commonTags             = "${var.commonTags}"
}

resource "aws_sns_topic" "dev-sns" {
  name         = "dev${lower(var.commonTags["environment"])}Alert"
  display_name = "dev${lower(var.commonTags["environment"])}"
}

##--------------/cloudwatch metric alerts for cloudfront
#=====pipeline stuff
module "codepipeline" {
  source          = "../modules/codePipeline"
  pipeline_name   = "${var.pipelineName}"
  github_username = "${var.githubUserName}"
  github_token    = "${var.githubToken}"
  github_repo     = "${var.githubRepo}"
}
