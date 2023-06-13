data "aws_secretsmanager_secret_version" "openmed-desa-db-key" {
  secret_id = "desa-db-keys"
}

locals {
  desa-db-keys = jsondecode(
    data.aws_secretsmanager_secret_version.openmed-desa-db-key.secret_string
  )
}

resource "aws_db_instance" "openmed-desa-db" {

  engine                 = "mysql"
  engine_version         = "8.0.28"
  allocated_storage      = 20
  storage_type           = "gp2"
  instance_class         = "db.t3.micro"
  identifier             = "openmed-desa-db"
  db_name                = "openmed"
  username               = local.desa-db-keys.username
  password               = local.desa-db-keys.password
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.openmed-desa-db-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.openmed-desa-subnet-group.id

  tags = {
    server = "desa"
  }
}
