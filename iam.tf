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
