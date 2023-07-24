
resource "aws_codestarconnections_connection" "example" {
  name          = "mygitconn"
  provider_type = "GitHub"
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

resource "aws_elastic_beanstalk_application" "q4_q_app" {
  provider = aws.west
  name     = "q4_q_application"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "q4-q-instance-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_elastic_beanstalk_environment" "env" {
  provider            = aws.west
  name                = "q4qenvironment"
  application         = aws_elastic_beanstalk_application.q4_q_app.name
  solution_stack_name = "64bit Windows Server 2019 v2.11.6 running IIS 10.0" ### another stack with dotnet4.8

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.instance_profile.name
  }
}