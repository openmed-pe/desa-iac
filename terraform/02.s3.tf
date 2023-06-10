resource "aws_s3_bucket" "openmed-desa-artifacts" {
  bucket = "openmed-desa-artifacts"
  tags = {
    server = "desa"
  }
}

resource "aws_s3_bucket_ownership_controls" "openmed-desa-artifacts-ownership" {
  bucket = aws_s3_bucket.openmed-desa-artifacts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "openmed-desa-artifacts-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.openmed-desa-artifacts-ownership]

  bucket = aws_s3_bucket.openmed-desa-artifacts.id
  acl    = "private"
}
