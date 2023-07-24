resource "aws_iam_policy" "codestar_policy" {
  name        = "q4_q_codestar_policy"
  description = "Policy to allow CodePipeline to use CodeStar connection"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codestar-connections:UseConnection"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:codestar-connections:us-east-1:944723394512:connection/b4df9521-14cf-4a00-879b-cafe2bd6bb89"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codestar_policy" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.codestar_policy.arn
}


resource "aws_iam_policy" "codebuild_start_policy" {
  name        = "q4_q_codebuild_start_policy"
  description = "Policy to allow CodePipeline to start CodeBuild"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codebuild:StartBuild"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:codebuild:us-east-1:944723394512:project/q4_q_project"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_start_policy_attachment" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.codebuild_start_policy.arn
}


resource "aws_iam_policy" "codebuild_batchget_policy" {
  name        = "q4_q_codebuild_batchget_policy"
  description = "Policy to allow CodePipeline to batch get builds in CodeBuild"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codebuild:BatchGetBuilds"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:codebuild:us-east-1:944723394512:project/q4_q_project"
        ]
      },
    ]
  })
}

resource "aws_iam_policy" "codebuild_elasticbeanstalk_policy" {
  name        = "q4_q_codebuild_elasticbeanstalk_policy"
  description = "Policy to allow CodePipeline to batch get builds in CodeBuild"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "elasticbeanstalk:CreateApplicationVersion"
        ]
        Effect = "Allow"
        "Resource" : "*"
      },
    ]
  })
}




resource "aws_iam_role_policy_attachment" "codebuild_batchget_policy_attachment" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.codebuild_batchget_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_elasticbeanstalk_policy_attachment" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.codebuild_elasticbeanstalk_policy.arn
}


resource "aws_iam_policy" "codebuild_logs_policy" {
  name        = "q4_q_codebuild_logs_policy"
  description = "Policy to allow CodeBuild to create log streams in CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:us-east-1:944723394512:log-group:/aws/codebuild/q4_q_project:*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_logs_policy_attachment" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild_logs_policy.arn
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
          "arn:aws:s3:::q4-q-bucket-app-user2023",
          "arn:aws:s3:::q4-q-west03bucket-app-user2023/*",
          "arn:aws:s3:::q4-q-west03bucket-app-user2023"
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



