output "cert_lb_arn" {
  value = aws_acm_certificate.cert_lb.arn
}

output "cert_cloudfront_arn" {
  value = aws_acm_certificate.cert_cloudfront.arn
}
