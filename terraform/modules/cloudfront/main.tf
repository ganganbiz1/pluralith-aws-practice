provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_cloudfront_distribution" "main" {
  enabled = true
  aliases = [
    var.api_domain
  ]

  http_version = "http2"
  is_ipv6_enabled = true

  origin {
    domain_name = var.lb_dns_name
    origin_id   = "${var.environment}-gangan-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = "${var.environment}-gangan-origin"
    compress        = true      

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["*"]
      /* headers = ["Accept", "Accept-Language", "Authorization", "CloudFront-Forwarded-Proto", "Host", "Origin", "Referer", "User-agent"] */
    }

    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.cert_cloudfront_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  logging_config {
    bucket = "${var.cloudfornt_log_bucket_name}.s3.amazonaws.com"
    include_cookies = false
    prefix = "api"
  }

  web_acl_id = var.waf_acl_arn
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = var.host_zone_id
  name    = var.api_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}
