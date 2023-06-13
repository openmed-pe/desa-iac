resource "aws_subnet" "openmed-subnet-public-east1a" {
  vpc_id                  = aws_vpc.openmed-vpc-desa.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "openmed-subnet-public-east1a"
  }
}

resource "aws_subnet" "openmed-subnet-public-east1b" {
  vpc_id                  = aws_vpc.openmed-vpc-desa.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "openmed-subnet-public-east1b"
  }
}

resource "aws_db_subnet_group" "openmed-desa-subnet-group" {
  name        = "openmed-desa-subnet-group"
  description = "DB subnet group for desa enviroment"
  subnet_ids  = [aws_subnet.openmed-subnet-public-east1a.id, aws_subnet.openmed-subnet-public-east1b.id]
}
