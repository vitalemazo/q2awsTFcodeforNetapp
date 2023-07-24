resource "aws_elastic_beanstalk_application" "q4_q_app" {
  provider = aws.west
  name     = "q4_q_application"
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