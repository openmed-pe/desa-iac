data "aws_s3_bucket" "openmed-desa-artifacts" {
  bucket = "openmed-desa-artifacts"
}

data "aws_iam_role" "role-codepipeline-desa" {
  name = "role-codepipeline-desa"
}

data "aws_iam_role" "role-codebuild-desa" {
  name = "role-codebuild-desa"
}

resource "aws_iam_role" "role-codedeploy-desa" {
  name = "role-codedeploy-desa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
      {
        "Effect" : "Allow",
        "Action" : ["codedeploy:CreateDeployment"],
        "Resource" : "*"
      },
    ]
  })

  tags = {
    server = "desa"
  }
}

resource "aws_iam_role_policy_attachment" "role-codedeploy-desa-attachment" {
  role       = aws_iam_role.role-codedeploy-desa.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_role" "role-ec2codedeploy-desa" {
  name = "role-ec2codedeploy-desa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    server = "desa"
  }
}

resource "aws_iam_role_policy_attachment" "role-ec2codedeploy-desa-attachment1" {
  role       = aws_iam_role.role-ec2codedeploy-desa.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "role-ec2codedeploy-desa-attachment2" {
  role       = aws_iam_role.role-ec2codedeploy-desa.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_instance_profile" "ec2codedeploy-desa-profile" {
  name = "ec2codedeploy-desa-profile"
  role = aws_iam_role.role-ec2codedeploy-desa.name
}
