provider "aws" {
  alias  = "west"
  region = "us-west-1"
}

provider "aws" {
  region = "us-east-1"
}
