locals {
  environment = "dev"
  domain = "ganganbiz.com"
  api_domain = "api.${local.domain}"
  api_service_name = "template-service-api"
  host_zone_id = "Z007697810QGLU9JE0I4X"
  cloudfornt_log_bucket_name = "aws-waf-logs-${local.environment}-gangan-bucket"
}

provider "aws" {
    region = "ap-northeast-1"
}

terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    # S3バケットとDynamoDBのテーブルは事前にマネージメントコンソールから手動で作成してください。
    bucket         = "dev-terraform-state-gangan-bucket"
    key            = "template-pj/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "dev-terraform-lock"
    encrypt        = true
  }
}

module "iam" {
  source = "./../../modules/iam"
  environment = local.environment
}

module "acm" {
  source = "./../../modules/acm"
  domain = local.domain
  api_domain = local.api_domain
  host_zone_id = local.host_zone_id
}

module "secrets_manager" {
  source = "./../../modules/secrets_manager"
  environment = local.environment
  secret_sample = "test"
  db_password = "test"
}

module "ses" {
  source = "./../../modules/ses"
  domain = local.domain
  host_zone_id = local.host_zone_id
}

module "vpc" {
  source = "./../../modules/vpc"
  environment = local.environment
}

module "alb" {
  source = "./../../modules/alb"
  environment = local.environment
  vpc_id = module.vpc.vpc_id
  subnet_public_1a_id = module.vpc.subnet_public_1a_id
  subnet_public_1c_id = module.vpc.subnet_public_1c_id
  security_group_alb_id = module.vpc.security_group_alb_id
  cert_lb_arn = module.acm.cert_lb_arn
}

module "ec2" {
  source = "./../../modules/ec2"
  environment = local.environment
  subnet_private_1a_id = module.vpc.subnet_private_1a_id
  subnet_private_1c_id = module.vpc.subnet_private_1c_id
  security_group_bastion_id = module.vpc.security_group_bastion_id
  ec2_ssm_instance_profile_id = module.iam.ec2_ssm_instance_profile_id
}

module "ecs" {
  source = "./../../modules/ecs"
  environment = local.environment
  subnet_private_1a_id = module.vpc.subnet_private_1a_id
  subnet_private_1c_id = module.vpc.subnet_private_1c_id
  security_group_ecs_id = module.vpc.security_group_ecs_id
  aws_lb_target_group_arn = module.alb.lb_target_group_arn
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
}

# RDSは時間かかるので、コメントアウト
# module "rds" {
#   source = "./../../modules/rds"
#   environment = local.environment
#   subnet_private_1a_id = module.vpc.subnet_private_1a_id
#   subnet_private_1c_id = module.vpc.subnet_private_1c_id
#   security_group_rds_id = module.vpc.security_group_rds_id
# }

module "s3" {
  source = "./../../modules/s3"
  environment = local.environment
  cloudfornt_log_bucket_name = local.cloudfornt_log_bucket_name
}

module "waf" {
  source = "./../../modules/waf"
  environment = local.environment
  waf_log_bucket_arn = module.s3.waf_log_bucket_arn
}

module "cloudfront" {
  source = "./../../modules/cloudfront"
  environment = local.environment
  lb_id = module.alb.aws_lb_id
  lb_dns_name = module.alb.aws_lb_dns_name
  api_domain = local.api_domain
  cert_cloudfront_arn = module.acm.cert_cloudfront_arn
  host_zone_id = local.host_zone_id
  waf_acl_arn = module.waf.waf_acl_arn
  cloudfornt_log_bucket_name = local.cloudfornt_log_bucket_name
}

