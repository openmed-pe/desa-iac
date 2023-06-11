resource "aws_codebuild_project" "openmed-codebuild-plan" {
  name         = "openmed-codebuild-plan"
  description  = "Plan stage for terraform desa environment"
  service_role = aws_iam_role.role-codebuild-desa.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = var.dockerhub_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("../devops/pipelines/plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "openmed-codebuild-apply" {
  name         = "openmed-codebuild-apply"
  description  = "Apply stage for terraform desa environment"
  service_role = aws_iam_role.role-codebuild-desa.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:0.14.3"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = var.dockerhub_credentials
      credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("../devops/pipelines/apply-buildspec.yml")
  }
}

resource "aws_codepipeline" "openmed-desa-iac-pipeline" {

  name     = "openmed-desa-iac-pipeline"
  role_arn = aws_iam_role.role-codepipeline-desa.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.openmed-desa-artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["tf-code"]
      configuration = {
        FullRepositoryId     = "openmed-pe/desa-iac"
        BranchName           = "master"
        ConnectionArn        = var.codestart_connector_credentials
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Plan"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "openmed-codebuild-plan"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "openmed-codebuild-apply"
      }
    }
  }

}
