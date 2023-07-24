resource "aws_s3_bucket_policy" "west_artifact_store" {
  bucket = aws_s3_bucket.westbucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowIncorrectEncryptionHeader"
        Effect    = "allow"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.westbucket.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      },
      {
        Sid       = "AllowUnEncryptedObjectUploads"
        Effect    = "allow"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.westbucket.arn}/*"
        Condition = {
          Null = {
            "s3:x-amz-server-side-encryption" = "true"
          }
        }
      }
    ]
  })
}

resource "aws_kms_key" "artifact_store_key" {
  description             = "KMS key for s3 bucket"
  deletion_window_in_days = 7
}

resource "aws_s3_bucket" "artifact_store" {
  bucket = "q4-q-bucket-app-user2023-unique"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.artifact_store_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}