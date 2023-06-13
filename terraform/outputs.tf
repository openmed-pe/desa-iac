output "ec2_public_id" {
  value      = aws_instance.openmed-desa-api.public_ip
  depends_on = [aws_instance.openmed-desa-api]
}

output "db_dns" {
  value = aws_db_instance.openmed-desa-db.address
}
