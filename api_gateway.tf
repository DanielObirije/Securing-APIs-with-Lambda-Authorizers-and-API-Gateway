 resource "aws_apigatewayv2_api" "secure_api" {
   name = "secure_api-apigateway-${local.name_surfix}"
   protocol_type = "HTTP"

   tags = local.common_tags
 }

 resource "aws_apigatewayv2_authorizer" "token_authorizer" {
   api_id = aws_apigatewayv2_api.secure_api.id
   name =  "TokenAuthorizer"
   authorizer_type = "REQUEST"
   authorizer_uri = aws_lambda_function.token_authorizer.invoke_arn
   authorizer_credentials_arn = aws_iam_role.api_gateway_authorizer_role.arn
   authorizer_payload_format_version = "2.0"
   enable_simple_responses = true

   identity_sources = [
     "$request.header.Authorization"
   ]
   authorizer_result_ttl_in_seconds = 300
 }

  resource "aws_apigatewayv2_authorizer" "request_authorizer" {
   api_id = aws_apigatewayv2_api.secure_api.id
   name =  "RequestAuthorizer"
   authorizer_type = "REQUEST"
   authorizer_uri = aws_lambda_function.request_authorizer.invoke_arn
   authorizer_credentials_arn = aws_iam_role.api_gateway_authorizer_role.arn
   authorizer_payload_format_version = "2.0"
   enable_simple_responses = true

   identity_sources = [
     "$request.header.X-Custom-Auth",
    "$request.querystring.api_key"
   ]
   authorizer_result_ttl_in_seconds = 300
 }

 resource "aws_apigatewayv2_integration" "public" {
    api_id = aws_apigatewayv2_api.secure_api.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.public_api.invoke_arn
    integration_method = "POST"
    payload_format_version = "2.0"
 }

 resource "aws_apigatewayv2_integration" "protected" {
    api_id = aws_apigatewayv2_api.secure_api.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.protected_api.invoke_arn
    integration_method = "POST"
    payload_format_version = "2.0"
 }

  resource "aws_apigatewayv2_integration" "admin" {
    api_id = aws_apigatewayv2_api.secure_api.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.protected_api.invoke_arn
    integration_method = "POST"
    payload_format_version = "2.0"
 }

 resource "aws_apigatewayv2_route" "Public" {
    api_id = aws_apigatewayv2_api.secure_api.id
    route_key = "GET /public"
    target = "integration/${aws_apigatewayv2_integration.public.id}"
 }

 resource "aws_apigatewayv2_route" "protected" {
  api_id             = aws_apigatewayv2_api.secure_api.id
  route_key          = "GET /protected"
  target             = "integrations/${aws_apigatewayv2_integration.protected.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.token_authorizer.id
}

resource "aws_apigatewayv2_route" "admin" {
  api_id             = aws_apigatewayv2_api.secure_api.id
  route_key          = "GET /protected/admin"
  target             = "integrations/${aws_apigatewayv2_integration.admin.id}"

  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.request_authorizer.id
}


resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.secure_api.id
  name        = local.api_stage_name
  auto_deploy = true

  dynamic "access_log_settings" {
    for_each = local.enable_cloudwatch_logs ? [1] : []

    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn

      format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        routeKey       = "$context.routeKey"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
      })
    }
  }

  tags = local.common_tags
}