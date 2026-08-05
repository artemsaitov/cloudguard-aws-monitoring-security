# CloudGuard AWS Monitoring and Security Response

CloudGuard is a Terraform-managed AWS monitoring and incident-response
platform built to demonstrate proactive infrastructure monitoring,
automated incident triage and cloud security response.

## Project objectives

- Create separated development and production EC2 environments
- Access EC2 instances securely through AWS Systems Manager
- Collect custom memory and disk metrics with the CloudWatch Agent
- Detect operational incidents using CloudWatch alarms
- Route notifications through Amazon SNS
- Automatically classify incidents with AWS Lambda
- Detect suspicious activity with Amazon GuardDuty
- Route security findings through Amazon EventBridge
- Practice investigation, containment and incident reporting

## Architecture

The project will use:

- Amazon VPC
- Amazon EC2
- AWS Systems Manager Session Manager
- Amazon CloudWatch
- Amazon SNS
- AWS Lambda
- Amazon EventBridge
- Amazon GuardDuty
- AWS IAM
- Terraform

## Project status

- [x] Repository foundation
- [ ] Networking
- [ ] EC2 and Systems Manager
- [ ] CloudWatch monitoring
- [ ] Operational incident triage
- [ ] GuardDuty security response
- [ ] Incident simulations
- [ ] Documentation and CI/CD

## Security principles

- No long-lived AWS credentials stored on EC2
- No private keys committed to Git
- IAM roles for AWS workloads
- Least-privilege permissions
- Separated development and production controls
- Human approval for potentially disruptive production remediation

## Deployment

Deployment instructions will be added as the project is implemented.

## Cleanup

Run `terraform destroy` after completing the lab to avoid unnecessary AWS
charges.