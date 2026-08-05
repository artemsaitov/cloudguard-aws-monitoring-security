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