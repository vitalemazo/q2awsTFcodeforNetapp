provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "role" {
  name = "q4q-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["elasticbeanstalk.amazonaws.com", "codebuild.amazonaws.com", "codepipeline.amazonaws.com"]
        }
      },
    ]
  })
}


resource "aws_codestarconnections_connection" "example" {
  name          = "mygitconn"
  provider_type = "GitHub"
}



resource "aws_codepipeline" "pipeline" {
  name     = "q4_q_pipeline"
  role_arn = aws_iam_role.pipeline.arn

  artifact_store {
    region   = "us-east-1"
    location = aws_s3_bucket.bucket.bucket
    type     = "S3"
  }

  artifact_store {
    region   = "us-west-1"
    location = aws_s3_bucket.westbucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {

        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:944723394512:connection/b4df9521-14cf-4a00-879b-cafe2bd6bb89"
        FullRepositoryId = "vitalemazo/MyQ2SamplewebApp"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      version = "1"

      configuration = {
        ProjectName = aws_codebuild_project.project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["build_output"]
      version         = "1"
      region          = "us-west-1" # Limitation need to go to another region cross-region action

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.q4_q_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.env.name
      }
    }
  }


}


resource "aws_codebuild_project" "project" {
  name        = "q4_q_project"
  description = "Build project for Windows"

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "mcr.microsoft.com/dotnet/framework/sdk:4.8" ## windows container with docker image
    type                        = "WINDOWS_SERVER_2019_CONTAINER"
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


resource "aws_iam_role" "pipeline" {
  name = "q4_q_pipeline-role"

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
  name = "q4_q_codebuild-role"

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

resource "aws_elastic_beanstalk_application" "q4_q_app" {
  name = "q4_q_application"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "q4-q-instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name = "q4-q-instance-role"



  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_elastic_beanstalk_environment" "env" {
  name                = "q4qenvironment"
  application         = aws_elastic_beanstalk_application.q4_q_app.name
  solution_stack_name = "64bit Windows Server 2019 v2.11.6 running IIS 10.0" ### another stack with dotnet4.8

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.instance_profile.name
  }
}

resource "aws_iam_policy" "s3_upload_policy" {
  name        = "q4_q_s3_upload_policy"
  description = "Policy to allow CodeBuild to upload to S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::q4-q-bucket-app-user2023/*",
          "arn:aws:s3:::q4-q-bucket-app-user2023"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_upload_policy_codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.s3_upload_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_upload_policy_codepipeline" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.s3_upload_policy.arn
}
