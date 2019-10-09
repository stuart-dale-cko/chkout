# Static Site with S3

## what does this do

To host a static website on AWS S3 with a Cloudfront distribution, Includes the following,
 *S3
 *cloudfront
 *route53
 *optional AWS CodePipeline

*This module also includes the creation of a public cert using AWS ACM, which is required to be hosted in US-EAST-1, failing to do this first will lead to the cloudfront_distro failure.*

## Prerequisite

 *An exsiting S3 bucket  - to host the tfstate backend
 *valid SSL in **us-east-1** if using the cloudfront distro
 *Terraform *this code was done in 0.11.*
 *AWS access keys

## Installation

 Set access keys in .aws config file or as an $ENV var powershell

```bash
$env:AWS_ACCESS_KEY_ID     = "key_id_here"
$env:AWS_SECRET_ACCESS_KEY = "secret_here"
$env:AWS_DEFAULT_REGION    = "eu-west-1"
```

comment out unrequired modules with a preceeding #
ie

```bash
 #module {
 #source = "../path/to modules  
 #}
```

run terraform init if all ok run terraform plan to verify what resources are to be created.
once satisfied run terraform apply to build resources

```bash
c:\git>terraform init
```

```bash
c:\git>terraform apply
```
