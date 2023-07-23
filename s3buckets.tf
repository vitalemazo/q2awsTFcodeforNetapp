resource "aws_s3_bucket" "bucket" {
  bucket = "q4-q-bucket-app-user2023" // change this to a unique name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "westbucket" {
  provider = aws.west
  bucket   = "q4-q-west03bucket-app-user2023"
  acl      = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}