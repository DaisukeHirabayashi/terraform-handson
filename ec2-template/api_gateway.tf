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

# cat
resource "aws_api_gateway_resource" "cat" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_rest_api.private.root_resource_id
  path_part   = "cat"
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

# dog
resource "aws_api_gateway_resource" "dog" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  parent_id   = aws_api_gateway_resource.cat.id
  path_part   = "dog"
}

resource "aws_api_gateway_method" "get_dog" {
  rest_api_id   = aws_api_gateway_rest_api.private.id
  resource_id   = aws_api_gateway_resource.dog.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.private.id
  resource_id             = aws_api_gateway_resource.dog.id
  http_method             = aws_api_gateway_method.get_dog.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda_function.invoke_arn
}

resource "aws_api_gateway_method_response" "response_dog_200" {
  rest_api_id = aws_api_gateway_rest_api.private.id
  resource_id = aws_api_gateway_resource.dog.id
  http_method = aws_api_gateway_method.get_dog.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "integration_response_200" {
  rest_api_id  = aws_api_gateway_rest_api.private.id
  resource_id  = aws_api_gateway_resource.dog.id
  http_method  = aws_api_gateway_method.get_dog.http_method
  status_code  = "200"

  depends_on = [ aws_api_gateway_integration.lambda_integration ]
}

resource "aws_api_gateway_deployment" "develop" {
  rest_api_id = aws_api_gateway_rest_api.private.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      data.archive_file.zip.output_base64sha256
    ]))
  }

  depends_on = [
    aws_lambda_function.my_lambda_function
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "staging" {
  deployment_id = aws_api_gateway_deployment.develop.id
  rest_api_id   = aws_api_gateway_rest_api.private.id
  stage_name    = "staging"
}