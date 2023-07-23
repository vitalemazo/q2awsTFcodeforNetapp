provider "aws" {
  region = "us-east-1"
}

resource "aws_codepipeline" "pipeline" {
  name     = "mypipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    location = aws_s3_bucket.bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = "***"
        Repo       = "***"
        Branch     = "main"
        #OAuthToken = "***"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "BuildAction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.example.name
      }
    }
  }
}

resource "aws_codebuild_project" "project" {
  name       = "myproject"
  description = "Build project for Windows"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "mcr.microsoft.com/dotnet/framework/sdk:4.8" ## windows container with docker image
    type                        = "WINDOWS_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "SOLUTION"
      value = "DotNetFrameworkApp.sln"
    }

    environment_variable {
      name  = "DOTNET_FRAMEWORK"
      value = "4.8"
    }

    environment_variable {
      name  = "PACKAGE_DIRECTORY"
      value = ".\\packages"
    }
  }

  service_role = aws_iam_role.codebuild.arn
}

resource "aws_codepipeline_webhook" "webhook" {
  name          = "mywebook"
  target_action = "SourceAction"
  target_pipeline = aws_codepipeline.webhook.mywebhook

  authentication {
    type     = "GITHUB_HMAC"
    secret_token = "***gihub***"
  }
}

resource "aws_iam_role" "pipeline" {
  name = "my-pipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "codebuild" {
  name = "my-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  # Attach additional policies as needed
  # e.g., AWSCodePipelineFullAccess, AmazonS3FullAccess, etc.
}

resource "aws_elastic_beanstalk_application" "myapp" {
  name = "my-application"
}

resource "aws_elastic_beanstalk_environment" "example" {
  name = "my-environment"
  application = aws_elastic_beanstalk_application.example.name
  solution_stack_name = "64bit Windows Server 2019 v4.8.3 running IIS 10.0" ### another stack with dotnet4.8
}
