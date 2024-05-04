provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

# 証明書発行リクエスト
resource "aws_acm_certificate" "cert_lb" {
  domain_name               = var.api_domain
  subject_alternative_names = [var.domain]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "cert_cloudfront" {
  domain_name       = var.api_domain
  validation_method = "DNS"
  provider          = aws.virginia # cloudfront用はバージニアリージョンに作成
  lifecycle {
    create_before_destroy = true
  }
}

# ACMのドメイン検証 - CloudFront用証明書
resource "aws_route53_record" "cert_validation_lb" {
  for_each = {
    for dvo in aws_acm_certificate.cert_lb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"

  zone_id = var.host_zone_id
}

resource "aws_route53_record" "cert_validation_cloudfront" {
  for_each = {
    for dvo in aws_acm_certificate.cert_cloudfront.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = "300"

  zone_id = var.host_zone_id
}
