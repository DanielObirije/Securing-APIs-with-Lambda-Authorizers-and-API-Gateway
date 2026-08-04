data "archive_file" "token_authorizer_zip"{
    type = "zip"
    output_path = "${path.module}/token_authorizer_zip"
    source {
      content = templatefile("${path.module}/functions/token_authorizer.py",{
        valid_tokens = jsonencode({
           principal_id = "regular-user"
           role         = "user"
           permissions  = "read"
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
      content = templatefile("${path.module}/functions/protected_api.py")
      filename = "protected_api.py"
    }
}

data "archive_file" "public_api_zip"{
    type = "zip"
    output_path = "${path.module}/public_api_zip"
    source {
      content = templatefile("${path.module}/functions/public_api.py")
      filename = "public_api.py"
    }
}


resource "aws_lambda_function" "token_authorizer" {
  filename = data.archive_file.token_authorizer_zip.output_path
  function_name = "request-authorizer-${local.name_surfix}"
  role = aws_iam_role.lambda_execution_role
  
}