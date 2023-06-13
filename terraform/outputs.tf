output "ec2_public_id" {
  value      = aws_instance.openmed-desa-api.public_ip
  depends_on = [aws_instance.openmed-desa-api]
}

output "db_address" {
  value = aws_db_instance.openmed-desa-db.address
}

output "s3_endpoint" {
  value = aws_s3_bucket.openmed-desa-public-bucket.website_endpoint
}


output "s3_bucket" {
  value = aws_s3_bucket.openmed-desa-public-bucket.bucket
}
