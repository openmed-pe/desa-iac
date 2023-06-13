resource "aws_instance" "openmed-desa-api" {
  ami           = "ami-0ce4307056314de2b"
  instance_type = "t2.micro"
  key_name      = "/elexito2023"
  subnet_id     = aws_subnet.openmed-subnet-public-east1a.id

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.openmed-desa-ec2-sg.id]

  tags = {
    Name = "openmed-desa-api"
  }
}
