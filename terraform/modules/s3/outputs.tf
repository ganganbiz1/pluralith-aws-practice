output "waf_log_bucket_arn" {
  value = aws_s3_bucket.waf_logs.arn
}
