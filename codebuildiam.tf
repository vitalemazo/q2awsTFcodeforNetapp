resource "aws_iam_policy" "codebuild_start_policy" {
  name        = "q2_q_codebuild_start_policy"
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
          "arn:aws:codebuild:us-east-1:944723394512:project/q2_q_project"
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
  name        = "q2_q_codebuild_batchget_policy"
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
          "arn:aws:codebuild:us-east-1:944723394512:project/q2_q_project"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_batchget_policy_attachment" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.codebuild_batchget_policy.arn
}


resource "aws_iam_policy" "codebuild_logs_policy" {
  name        = "q2_q_codebuild_logs_policy"
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
          "arn:aws:logs:us-east-1:944723394512:log-group:/aws/codebuild/q2_q_project:*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_logs_policy_attachment" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild_logs_policy.arn
}
