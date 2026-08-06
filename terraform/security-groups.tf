resource "aws_security_group" "dev" {
  name        = "${local.name_prefix}-dev-sg"
  description = "Security group for the CloudGuard development server."
  vpc_id      = aws_vpc.cloudguard.id

  egress {
    description = "Allow outbound traffic required for package installation and AWS services."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name_prefix}-dev-sg"
    Environment = "Dev"
  }
}

resource "aws_security_group" "prod" {
  name        = "${local.name_prefix}-prod-sg"
  description = "Security group for the CloudGuard production server."
  vpc_id      = aws_vpc.cloudguard.id

  egress {
    description = "Allow outbound traffic required for package installation and AWS services."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${local.name_prefix}-prod-sg"
    Environment = "Production"
  }
}