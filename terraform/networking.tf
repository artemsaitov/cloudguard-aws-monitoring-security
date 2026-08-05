resource "aws_vpc" "cloudguard" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "cloudguard" {
  vpc_id = aws_vpc.cloudguard.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_subnet" "dev" {
  vpc_id                  = aws_vpc.cloudguard.id
  cidr_block              = var.dev_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.name_prefix}-dev-subnet"
    Environment = "Dev"
    Tier        = "Public"
  }
}

resource "aws_subnet" "prod" {
  vpc_id                  = aws_vpc.cloudguard.id
  cidr_block              = var.prod_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.name_prefix}-prod-subnet"
    Environment = "Production"
    Tier        = "Public"
  }
}

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.cloudguard.id

  tags = {
    Name        = "${local.name_prefix}-dev-route-table"
    Environment = "Dev"
  }
}

resource "aws_route" "dev_internet" {
  route_table_id         = aws_route_table.dev.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cloudguard.id
}

resource "aws_route_table_association" "dev" {
  subnet_id      = aws_subnet.dev.id
  route_table_id = aws_route_table.dev.id
}

resource "aws_route_table" "prod" {
  vpc_id = aws_vpc.cloudguard.id

  tags = {
    Name        = "${local.name_prefix}-prod-route-table"
    Environment = "Production"
  }
}

resource "aws_route" "prod_internet" {
  route_table_id         = aws_route_table.prod.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cloudguard.id
}

resource "aws_route_table_association" "prod" {
  subnet_id      = aws_subnet.prod.id
  route_table_id = aws_route_table.prod.id
}
