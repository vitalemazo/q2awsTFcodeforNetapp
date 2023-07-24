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

        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:944723394512:connection/1e13431d-bbee-4237-b64f-57eba468a405"
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
