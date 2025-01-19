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
