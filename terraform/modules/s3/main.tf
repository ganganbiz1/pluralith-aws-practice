resource "aws_s3_bucket" "waf_logs" {
  bucket = var.cloudfornt_log_bucket_name
}

resource "aws_s3_bucket_versioning" "waf_logs_versioning" {
  bucket = aws_s3_bucket.waf_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "waf_logs_lifecycle" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    id     = "log-lifecycle-rule"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "waf_logs_policy" {
    bucket = aws_s3_bucket.waf_logs.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs_enc_config" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "waf_logs_policy" {
  bucket = aws_s3_bucket.waf_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:PutObject"
        Effect = "Allow"
        Resource = "${aws_s3_bucket.waf_logs.arn}/*"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
      },
      {
        Action = "s3:GetBucketAcl"
        Effect = "Allow"
        Resource = aws_s3_bucket.waf_logs.arn
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_s3_bucket_ownership_controls" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    object_ownership = "ObjectWriter"
  }
}