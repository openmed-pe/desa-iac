data "aws_secretsmanager_secret" "ec2_secretkey" {
  name = "ec2desakey"
}

data "aws_secretsmanager_secret_version" "ec2_secretkey" {
  secret_id = data.aws_secretsmanager_secret.ec2_secretkey.id
}

locals {
  ec2_secretkey = data.aws_secretsmanager_secret_version.ec2_secretkey.secret_string
}

resource "aws_instance" "openmed-desa-api" {
  ami           = "ami-0ce4307056314de2b"
  instance_type = "t2.micro"
  key_name      = "/elexito2023"
  subnet_id     = aws_subnet.openmed-subnet-public-east1a.id

  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.openmed-desa-ec2-sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2codedeploy-desa-profile.name

  tags = {
    Name = "openmed-desa-api"
  }

  provisioner "remote-exec" {
    script = "../devops/scripts/install_codedeploy_agent.sh"

    connection {
      agent       = false
      type        = "ssh"
      user        = "ec2-user"
      private_key = local.ec2_secretkey
    }
  }
}
