resource "aws_vpc" "openmed-vpc-desa" {
  cidr_block = "10.10.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "openmed-vpc-main"
  }
}
