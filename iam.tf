resource "aws_iam_policy" "codestar_policy" {
  name        = "q2_q_codestar_policy"
  description = "Policy to allow CodePipeline to use CodeStar connection"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "codestar-connections:UseConnection"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:codestar-connections:us-east-1:944723394512:connection/72560fc3-ca96-4134-97f2-30275faf451a"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codestar_policy" {
  role       = aws_iam_role.pipeline.name
  policy_arn = aws_iam_policy.codestar_policy.arn
}
