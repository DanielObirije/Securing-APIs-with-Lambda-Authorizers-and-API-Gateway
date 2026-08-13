
resource "aws_iam_role" "lambda_execution_role" {
  name = "secure-api-lambda-role-${local.name_surfix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    role = aws_iam_role.lambda_execution_role.name
}




resource "aws_iam_role" "api_gateway_authorizer_role" {
  name = "secure-api-authorizer-role-${local.name_surfix}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
tags = local.common_tags
}


resource "aws_iam_role_policy" "api_gateway_authorizer_policy" {
   name = "secure-api-authorizer-policy-${local.name_surfix}"
   role = aws_iam_role.api_gateway_authorizer_role.id
   policy = jsonencode({
    Version= "2012-11-17"
    Statement=[
       {
        Effect = "Allow"
         Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
           aws_lambda_function.token_authorizer.arn,
           aws_lambda_function.request_authorizer.arn
        ]
       }
    ]
   })
}