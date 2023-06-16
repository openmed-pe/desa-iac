
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

# create a CodeDeploy application
resource "aws_codedeploy_app" "openmed-codedeploy-buildApi-app" {
  name = "openmed-codedeploy-buildApi-app"
}

# create a deployment group
resource "aws_codedeploy_deployment_group" "openmed-codedeploy-buildApi-group" {
  app_name              = aws_codedeploy_app.openmed-codedeploy-buildApi-app.name
  deployment_group_name = "codedeploy-buildApi-group"
  service_role_arn      = aws_iam_role.role-codedeploy-desa.arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "openmed-desa-api"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
    ]
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
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      provider         = "CodeBuild"
      version          = "1"
      owner            = "AWS"
      input_artifacts  = ["api-code"]
      output_artifacts = ["api-build-code"]
      configuration = {
        ProjectName = "openmed-codebuild-buildApi"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToEC2"
      input_artifacts = ["api-build-code"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.openmed-codedeploy-buildApi-app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.openmed-codedeploy-buildApi-group.deployment_group_name
        AppSpecTemplatePath = "appspec.yml"
      }
    }
  }
}
