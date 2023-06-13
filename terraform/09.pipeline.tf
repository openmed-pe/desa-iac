data "aws_s3_bucket" "openmed-desa-artifacts" {
  bucket = "openmed-desa-artifacts"
}

data "aws_iam_role" "role-codepipeline-desa" {
  name = "role-codepipeline-desa"
}

data "aws_iam_role" "role-codebuild-desa" {
  name = "role-codebuild-desa"
}

resource "aws_codebuild_project" "openmed-codebuild-buildApi" {
  name         = "openmed-codebuild-buildApi"
  description  = "Build api for desa environment"
  service_role = data.aws_iam_role.role-codebuild-desa.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "node:14.7.0-alpine3.10"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = var.dockerhub_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("../devops/pipelines/buildApi-buildspec.yml")
  }
}

resource "aws_codepipeline" "openmed-desa-api-pipeline" {

  name     = "openmed-desa-api-pipeline"
  role_arn = data.aws_iam_role.role-codepipeline-desa.arn

  artifact_store {
    type     = "S3"
    location = data.aws_s3_bucket.openmed-desa-artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["api-code"]
      configuration = {
        FullRepositoryId     = "openmed-pe/api-full-back"
        BranchName           = "master"
        ConnectionArn        = var.codestart_connector_credentials
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Commit"
    action {
      name             = "Build"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["api-code"]
      output_artifacts = ["api-code"]
      configuration = {
        ProjectName = "openmed-codebuild-buildApi"
      }
    }
  }

}
