provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "role" {
  name = "q2q-service-role"
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



resource "aws_s3_bucket" "bucket" {
  bucket = "q2-q-bucket-app-user2023" // change this to a unique name
  acl    = "private"



  versioning {
    enabled = true
  }



  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = "q2_q_pipeline"
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
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {

        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:944723394512:connection/72560fc3-ca96-4134-97f2-30275faf451a"
        FullRepositoryId = "vitalemazo/MyQ2SamplewebApp"
        BranchName       = "main"
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
      version         = "2"

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.q2_q_app.name
        EnvironmentName = aws_elastic_beanstalk_environment.env.name
      }
    }
  }












}


resource "aws_codebuild_project" "project" {
  name        = "q2_q_project"
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
  name = "q2_q_pipeline-role"

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
  name = "q2_q_codebuild-role"

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

resource "aws_elastic_beanstalk_application" "q2_q_app" {
  name = "q2_q_application"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "q2-q-instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name = "q2-q-instance-role"



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
  name                = "q2qenvironment"
  application         = aws_elastic_beanstalk_application.q2_q_app.name
  solution_stack_name = "64bit Windows Server 2019 v2.11.6 running IIS 10.0" ### another stack with dotnet4.8

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.instance_profile.name
  }
}




resource "aws_iam_policy" "s3_upload_policy" {
  name        = "q2_q_s3_upload_policy"
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
          "arn:aws:s3:::q2-q-bucket-app-user2023/*",
          "arn:aws:s3:::q2-q-bucket-app-user2023"
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
