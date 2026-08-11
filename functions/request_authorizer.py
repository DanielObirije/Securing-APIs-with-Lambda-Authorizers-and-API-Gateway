import json
from urllib.parse import parse_qs
import ipaddress

def lambda_handler(event, context):
    print(f"Request Authorizer Events:{json.dump(event)}")
    headers = event.get("headers",{})
    query_params = event.get("queryStringParameters",{}) or {}
    method_arn = event.get("methodArn","")
    source_ip = event.get("requestContext",{}).get("identity",{}).get("sourceIp","unknown")
    api_key = query_params.get("api_key","")
    custom_auth = headers.get("X-Custom-Auth","")
    valid_api_key = "secret-api-key-123"
    custom_auth_values = "custom-auth-value"
    principal_id = "unknown"
    effect = "Deny"
    context = {}

    if api_key == valid_api_key:
        principal_id = "api-key-user"
        effect = "Allow"
        context = {
            "authType": "api-key",
            "sourceIp": source_ip,
            "permissions": "read,write"
        }
    elif custom_auth == custom_auth_values:
        principal_id = "custom-user"
        effect = "Allow"
        context = {
          "authType": "custom-header",
          "sourceIp": source_ip,
          "permissions": "read"         
        }
    elif ipaddress.ip_address(source_ip).is_private:
        principal_id = "internal-user"
        effect = "Allow"
        context = {
           "authType": "ip-whitelist",
           "sourceIp": source_ip,
           "permissions": "read,write,delete"                         
        }       
    policy = generate_policy(principal_id,effect,method_arn,context)
    print(f"Generated Policy:{json.dumps(policy)}")
    return policy


def generate_policy(principal_id,effect,resource,context=None):
    policy = {
        "principal": principal_id,
        "policyDocument":{
            "Version": "2012-10-17",
            "Statement":[
                  {
                      "Action": "execute-api:Invoke",
                      "Effect": effect,
                      "Resource": resource
                  }
            ]
        }
    }
    if context:
        policy["context"] = context
    return policy

