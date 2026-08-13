data "archive_file" "token_authorizer_zip"{
    type = "zip"
    output_path = "${path.module}/token_authorizer_zip"
    source {
      content = templatefile("${path.module}/functions/token_authorizer.py",{
        valid_tokens = jsonencode({
            "admin-token": {
                "principal_id": "admin-user",
                "role": "admin",
                "permissions": "read,write,delete"
            },
            "user-token": {
                "principal_id": "regular-user",
                "role": "user",
                "permissions": "read"
            }
        })
      })
      filename = "token_authorizer.py"
    }
}

data "archive_file" "request_authorizer_zip"{
    type = "zip"
    output_path = "${path.module}/request_authorizer_zip"
    source {
      content = templatefile("${path.module}/functions/request_authorizer.py",{
        valid_api_keys = jsonencode("secret-api-key-123")
        custom_auth_values =jsonencode("custom-auth-value")
      })
      filename = "request_authorizer.py"
    }
}

data "archive_file" "protected_api_zip"{
    type = "zip"
    output_path = "${path.module}/protected_api_zip"
    source {
      content = file("${path.module}/functions/protected_api.py")
      filename = "protected_api.py"
    }
}

data "archive_file" "public_api_zip"{
    type = "zip"
    output_path = "${path.module}/public_api_zip"
    source {
      content = file("${path.module}/functions/public_api.py")
      filename = "public_api.py"
    }
}


resource "aws_lambda_function" "token_authorizer" {
  filename = data.archive_file.token_authorizer_zip.output_path
  function_name = "token-authorizer-${local.name_surfix}"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "token_authorizer.lambda_handler"
  runtime = "python3.9"
  timeout = 30
  source_code_hash = data.archive_file.token_authorizer_zip.output_base64sha256
  description = "Token-based API Gateway authorizer function"

  depends_on = [ 
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_cloudwatch_log_group.api_gateway_logs
   ]

  tags = local.common_tags
}

resource "aws_lambda_function" "request_authorizer" {
  filename = data.archive_file.request_authorizer_zip.output_path
  function_name = "request-authorizer-${local.name_surfix}"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "request_authorizer.lambda_handler"
  runtime = "python3.9"
  timeout = 30
  source_code_hash = data.archive_file.request_authorizer_zip.output_base64sha256
  description = "Request-based API Gateway authorizer function"

   depends_on = [ 
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_cloudwatch_log_group.api_gateway_logs
   ]
  tags = local.common_tags
}

resource "aws_lambda_function" "protected_api" {
  filename = data.archive_file.protected_api_zip.output_path
  function_name = "protected-api-${local.name_surfix}"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "protected_api.lambda_handler"
  runtime = "python3.9"
  timeout = 30
  source_code_hash = data.archive_file.protected_api_zip.output_base64sha256
  description = "Protected API function requiring authorization"

   depends_on = [ 
      aws_iam_role_policy_attachment.lambda_basic_execution,
      aws_cloudwatch_log_group.api_gateway_logs
   ]

  tags = local.common_tags
}


resource "aws_lambda_function" "public_api" {
  filename = data.archive_file.public_api_zip.output_path
  function_name = "public_api-${local.name_surfix}"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "public_api.lambda_handler"
  runtime = "python3.9"
  timeout = 30
  source_code_hash = data.archive_file.public_api_zip.output_base64sha256
  description = "Public API function without authorization requirements"

  depends_on = [ 
      aws_iam_role_policy_attachment.lambda_basic_execution,
      aws_cloudwatch_log_group.api_gateway_logs
   ]

  tags = local.common_tags
}

