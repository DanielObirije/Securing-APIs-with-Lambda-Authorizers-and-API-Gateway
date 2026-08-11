import json
import os

valid_tokens = {
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
}

def lambda_handler(event,context):
    print(f"Token Authorizer Event: {json.dumps(event)}")

    token = event.get("authorizationToken", "")
    method_arn = event.get("methodArn", "")

    if not token.startswith("Bearer "):
        raise Exception("Unauthorized")

    actual_token = token.replace("Bearer ", "",1)

    if actual_token not in valid_tokens:
         raise Exception("Unauthorized")
    
    token_info = valid_tokens[actual_token]

    policy = generate_policy(
       token_info['principal_id'],
        'Allow',
        method_arn,
        {
            'role': token_info['role'],
            'permissions': token_info['permissions']
        }
    )

    print(f"Generated Policy: {json.dumps(policy)}")
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


    
