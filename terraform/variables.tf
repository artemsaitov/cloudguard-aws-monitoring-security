variable "aws_region" {
  description = "AWS Region where CloudGuard resources will be deployed."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS Region name."
  }
}

variable "project_name" {
  description = "Name used to identify CloudGuard resources."
  type        = string
  default     = "cloudguard"
}

variable "alert_email" {
  description = "Email address that will receive CloudGuard alarm notifications."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be a valid email address."
  }
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the CloudGuard VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "dev_subnet_cidr" {
  description = "CIDR block assigned to the development subnet."
  type        = string
  default     = "10.20.1.0/24"
}

variable "prod_subnet_cidr" {
  description = "CIDR block assigned to the production subnet."
  type        = string
  default     = "10.20.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type used for the Dev and Production lab servers."
  type        = string
  default     = "t3.micro"
}
