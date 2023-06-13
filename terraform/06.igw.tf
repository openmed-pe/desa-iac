resource "aws_internet_gateway" "openmed-desa-vpc-igw" {
  vpc_id = aws_vpc.openmed-vpc-desa.id

  tags = {
    Name = "openmed-desa-vpc-igw"
  }
}
