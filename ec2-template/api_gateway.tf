resource "aws_api_gateway_rest_api" "private" {
  name        = var.service_name
  description = "プライベートAPI検証用API Gateway"

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = [aws_vpc_endpoint.ec2.id]
  }

  policy = data.aws_iam_policy_document.private_api.json
}

data "aws_iam_policy_document" "private_api" {
  statement {
    effect = "Allow"

    principals {
      type = "*"
      identifiers = [
        "*",
      ]
    }

    actions = [
      "execute-api:Invoke",
    ]

    resources = [
      "*",
    ]
  }
  statement {
    effect = "Deny"

    principals {
      type = "*"
      identifiers = [
        "*",
      ]
    }

    actions = [
      "execute-api:Invoke",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"

      values = [
        aws_vpc_endpoint.ec2.id,
      ]
    }
  }
}

resource "aws_api_gateway_resource" "cat" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_rest_api.private.root_resource_id
  path_part   = "cat"
}

resource "aws_api_gateway_resource" "dog" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_resource.cat.id
  path_part   = "dog"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.private.id
  resource_id   = aws_api_gateway_resource.cat.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cat_integration" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  resource_id = aws_api_gateway_resource.cat.id
  http_method = aws_api_gateway_method.get_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = <<EOF
{
   "statusCode" : 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  resource_id = aws_api_gateway_resource.cat.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  resource_id = aws_api_gateway_resource.cat.id
  http_method = aws_api_gateway_method.get_method.http_method
  status_code = "200"

  response_templates = {
    "application/json" = <<EOF
{
   "id" : 1,
   "name": "tama"
}
EOF  
  }
}

