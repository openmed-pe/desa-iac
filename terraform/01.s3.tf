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
