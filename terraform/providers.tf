provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Environment = "Shared"
      Repository  = "cloudguard-aws-monitoring-security"
    }
  }
}
