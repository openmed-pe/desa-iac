resource "aws_s3_bucket" "openmed-desa-public-bucket" {
  bucket = "openmed-desa-public-bucket"

  tags = {
    server = "desa"
  }
}

resource "aws_s3_bucket_public_access_block" "openmed-desa-public-bucket" {
  bucket = aws_s3_bucket.openmed-desa-public-bucket.id

  block_public_acls   = false
  block_public_policy = false

}

resource "aws_s3_bucket_ownership_controls" "openmed-desa-public-bucket-ownership" {
  bucket = aws_s3_bucket.openmed-desa-public-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "openmed-desa-public-bucket-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.openmed-desa-public-bucket-ownership]

  bucket = aws_s3_bucket.openmed-desa-public-bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "openmed-desa-public-bucket" {
  bucket = aws_s3_bucket.openmed-desa-public-bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::openmed-desa-public-bucket/*"
      }
  ]
}
POLICY
}
