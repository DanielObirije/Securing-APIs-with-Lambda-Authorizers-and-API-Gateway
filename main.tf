data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_id" "surffix" {
 byte_length = 3
}


locals {
  name_surfix = random_id.surffix.hex
  common_tags = merge(
    {
        Project = "ServerlessAPIPatterns"
        Environment = "dev"
        ManagedBy = "terraform"
        Recipe = "serverless-api-patterns-lambda-authorizers-api-gateway"
    }
  )
}