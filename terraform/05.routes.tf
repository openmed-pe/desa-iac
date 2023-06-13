resource "aws_route_table" "openmed-route-public" {
  vpc_id = aws_vpc.openmed-vpc-desa.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.openmed-desa-vpc-igw.id
  }

  tags = {
    Name = "openmed-route-public"
  }
}

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.openmed-subnet-public-east1a.id
  route_table_id = aws_route_table.openmed-route-public.id
}
