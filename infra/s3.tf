
## Buckets to save tf state remotely
resource "aws_s3_bucket" "tf_backend_bucket" {
  bucket        = "tf-state-backend-35471530"
  force_destroy = true

  tags = {
    Environment = "excercise"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "tf_backend" {
  bucket = aws_s3_bucket.tf_backend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "daily_DB_backups" {
  bucket        = "mongo-db-backups-35471530"
  force_destroy = true

}

resource "aws_s3_bucket_ownership_controls" "backups_ownership_controls" {
  bucket = aws_s3_bucket.daily_DB_backups.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.daily_DB_backups.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "s3_pub_policy" {
  statement {
    sid = "PublicReadGetObject"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.daily_DB_backups.arn,
      "${aws_s3_bucket.daily_DB_backups.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_pub_policy" {
  bucket = aws_s3_bucket.daily_DB_backups.id
  policy = data.aws_iam_policy_document.s3_pub_policy.json
}
