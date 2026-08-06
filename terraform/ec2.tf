locals {
  cloudwatch_agent_config = templatefile(
    "${path.module}/../cloudwatch-agent/config.json.tftpl",
    {}
  )
}

resource "aws_instance" "dev" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.dev.id
  vpc_security_group_ids      = [aws_security_group.dev.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_monitoring.name
  associate_public_ip_address = true

  user_data = templatefile(
    "${path.module}/user-data/dev.sh.tftpl",
    {
      cloudwatch_agent_config = local.cloudwatch_agent_config
    }
  )

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring = true

  tags = {
    Name        = "${local.name_prefix}-dev-server"
    Environment = "Dev"
    Role        = "MonitoredServer"
  }
}

resource "aws_instance" "prod" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.prod.id
  vpc_security_group_ids      = [aws_security_group.prod.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_monitoring.name
  associate_public_ip_address = true

  user_data = templatefile(
    "${path.module}/user-data/prod.sh.tftpl",
    {
      cloudwatch_agent_config = local.cloudwatch_agent_config
    }
  )

  user_data_replace_on_change = true

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring = true

  tags = {
    Name        = "${local.name_prefix}-prod-server"
    Environment = "Production"
    Role        = "MonitoredServer"
  }
}