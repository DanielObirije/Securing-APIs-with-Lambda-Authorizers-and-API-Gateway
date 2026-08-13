import json
import time


def lambda_handler(event,context):
    http_method = event.get("httpMethod", "GET")
    path = event.get("path","/")
    query_params = event.get("queryStringParameters",{}) or {}
    headers = event.get("headers",{})
    source_ip = event.get("requestContext",{}).get("identity",{}).get("sourceIp","unknown")
    user_agent = headers.get("User-Agent","unknown")


    respond_data = {
            "message": "Access granted to protected resource",
            "status": "operational",
            "timestamp": int(time.time()),
            "request_id": context.aws_request_id,
            "request_info": {
                "method":  http_method,
                "path": path,
                "source_ip": source_ip,
                "user_agent": user_agent,
                "query_parameters": query_params
            },
            "public_data":{
                 "api_version": "1.0",
                 "service_name": "Serverless API Pattern Demo",
                "avalaible_endpoints": [
                    { 
                        "path": "/public",
                        "method": "GET",
                        "authorization": "None",
                        "description": "Public endpoint accessible without authentication"
                    },
                    {
                        "path": "/protected",
                        "method": "GET", 
                        "authorization": "Bearer Token",
                        "description": "Protected endpoint requiring valid bearer token"
                    },
                    {
                        "path": "/protected/admin",
                        "method": "GET",
                        "authorization": "API Key or Custom Header",
                        "description": "Admin endpoint with request-based authorization"
                    }
                ]
            },
            "system_info":{
                "function_name": context.function_name,
                "memory_limit": context.memory_limit_in_mb,
                "remaining_time_ms": context.get_remaining_time_in_millis(),
                "log_group": context.log_group_name,
                "log_stream": context.log_stream_name
            }
    }

    return {
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "X-API-Version": "1.0",
            "X-Service-Type": "public"
        },
        "body": json.dumps(respond_data,indent=2)
    }
    

