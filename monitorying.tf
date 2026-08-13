resource "aws_cloudwatch_log_group" "token_authorizer_logs" {
    name = "/aws/lambda/token-authorizer-${local.name_surfix}"
    retention_in_days = 14
    tags =  local.common_tags
}

resource "aws_cloudwatch_log_group" "request_authorizer_logs" {
    name = "/aws/lambda/request-authorizer-${local.name_surfix}"
    retention_in_days = 14
    tags =  local.common_tags
}

resource "aws_cloudwatch_log_group" "protected_authorizer_logs" {
    name = "/aws/lambda/protected-api-${local.name_surfix}"
    retention_in_days = 14
    tags =  local.common_tags
}

resource "aws_cloudwatch_log_group" "public_authorizer_logs" {
    name = "/aws/lambda/public-api-${local.name_surfix}"
    retention_in_days = 14
    tags =  local.common_tags
}

resource "aws_cloudwatch_log_group" "api_gateway_logs" {
    name = "/aws/lambda/apigatway-log-${aws_apigatewayv2_api.secure_api.id}/${local.api_stage_name}"
    retention_in_days = 14
    tags =  local.common_tags
}