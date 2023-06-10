resource "aws_iam_role" "role-codepipeline-desa" {
  name = "role-codepipeline-desa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    server = "desa"
  }
}

data "aws_iam_policy_document" "policies-pipelines-desa" {
  statement {
    sid       = ""
    actions   = ["codestar-connections:UseConnection"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    sid       = ""
    actions   = ["cloudwatch:*", "s3:*", "codebuild:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "policy-pipelines-desa" {
  name        = "policy-pipelines-desa"
  path        = "/"
  description = "Pipeline policy"
  policy      = data.aws_iam_policy_document.policies-pipelines-desa.json
}

resource "aws_iam_role_policy_attachment" "role-codepipeline-desa-attachment" {
  policy_arn = aws_iam_policy.policy-pipelines-desa.arn
  role       = aws_iam_role.role-codepipeline-desa.id
}

resource "aws_iam_role" "role-codebuild-desa" {
  name = "role-codebuild-desa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })

}

data "aws_iam_policy_document" "policies-codebuild-desa" {
  statement {
    sid       = ""
    actions   = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*", "iam:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "policy-codebuild-desa" {
  name        = "policy-codebuild-desa"
  path        = "/"
  description = "Codebuild policy"
  policy      = data.aws_iam_policy_document.policies-codebuild-desa.json
}

resource "aws_iam_role_policy_attachment" "role-codebuild-desa-attachment1" {
  policy_arn = aws_iam_policy.policy-codebuild-desa.arn
  role       = aws_iam_role.role-codebuild-desa.id
}

resource "aws_iam_role_policy_attachment" "role-codebuild-desa-attachment2" {
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  role       = aws_iam_role.role-codebuild-desa.id
}
