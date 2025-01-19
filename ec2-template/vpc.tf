resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.service_name
  }
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-west-2a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.service_name}-public-subnet"
    Type    = "public"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.service_name}-rtb"
  }
}

# Route tableと subnetの関連付け
resource "aws_route_table_association" "public_rtb" {
  route_table_id = aws_route_table.rtb.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.service_name}-igw"
  }
}

# Route tableとIGWの関連付け
resource "aws_route" "rtb_igw_route" {
  route_table_id         = aws_route_table.rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
