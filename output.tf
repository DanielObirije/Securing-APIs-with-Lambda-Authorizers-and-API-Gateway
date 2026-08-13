output "api_gateway_url" {
  description = "Base URL for the API Gateway"
  value       = "https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}"
}

output "api_endpoints" {
  description = "Available API endpoints with their authorization requirements"
  value = {
    public_endpoint = {
      url            = "https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}/public"
      method         = "GET"
      authorization  = "None"
      description    = "Public endpoint accessible without authentication"
    }
    protected_endpoint = {
      url            = "https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}/protected"
      method         = "GET"
      authorization  = "Bearer Token"
      description    = "Protected endpoint requiring valid bearer token"
      test_tokens    = "admin-token, user-token"
    }
    admin_endpoint = {
      url            = "https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}/protected/admin"
      method         = "GET"
      authorization  = "API Key or Custom Header"
      description    = "Admin endpoint with request-based authorization"
      auth_methods   = "api_key parameter or X-Custom-Auth header"
    }
  }
}

output "test_commands" {
  description = "Sample curl commands for testing the API endpoints"
  value = {
    public_test = "curl -s 'https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}/public'"
    
    protected_user_test = "curl -s -H 'https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}/protected'"
    
    protected_admin_test = "curl -s -H 'https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}/protected'"
    
    admin_api_key_test = "curl -s 'https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}/protected/admin?api_key=secret-api-key-123'"
    
    admin_header_test = "curl -s -H 'X-Custom-Auth: custom-auth-value' 'https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}/protected/admin'"
    
    unauthorized_test = "curl -s 'https://${aws_apigatewayv2_api.secure_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_apigatewayv2_stage.api_stage.name}/protected'"
  }
}