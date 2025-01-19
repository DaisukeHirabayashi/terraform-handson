resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-west-2.execute-api" # apigatewayを呼び出すためのvpc end-point
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_vpc.main.default_security_group_id,
  ]

  subnet_ids = [
    aws_instance.ec2.subnet_id
  ]

  private_dns_enabled = true
}
