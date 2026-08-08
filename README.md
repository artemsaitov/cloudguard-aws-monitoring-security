# CloudGuard — AWS Monitoring and Automated Incident Triage

CloudGuard is a Terraform-managed AWS monitoring and incident-triage platform designed to demonstrate proactive infrastructure monitoring across Development and Production environments.

The project uses Amazon EC2, CloudWatch, CloudWatch Agent, SNS, Lambda, Systems Manager and IAM to detect infrastructure issues, notify operators and automatically classify incidents.

The infrastructure is fully managed with Terraform and validated through GitHub Actions.

---

## Project Scenario

CloudGuard experienced an operational incident where abnormal system behavior was not detected quickly enough, resulting in avoidable downtime.

The objective of this project was to build a proactive monitoring platform capable of:

- Monitoring Development and Production EC2 environments
- Collecting host-level memory and disk metrics
- Detecting sustained infrastructure issues
- Notifying operators automatically
- Triggering Lambda-based incident triage
- Recording incident context directly on affected EC2 instances
- Tracking both incident detection and recovery
- Managing the environment through Infrastructure as Code

---

## Architecture

```text
                         ┌─────────────────────┐
                         │      Terraform      │
                         │ Infrastructure Code │
                         └──────────┬──────────┘
                                    │
                   ┌────────────────┴────────────────┐
                   │                                 │
          ┌────────▼────────┐               ┌────────▼─────────┐
          │ Development EC2 │               │ Production EC2   │
          │                 │               │                  │
          │ Amazon Linux    │               │ Amazon Linux     │
          │ CloudWatch Agent│               │ CloudWatch Agent │
          │ stress-ng       │               │ disk test tools  │
          └────────┬────────┘               └────────┬─────────┘
                   │                                 │
                   └───────────────┬─────────────────┘
                                   │
                         ┌─────────▼──────────┐
                         │ Amazon CloudWatch  │
                         │ Metrics / Alarms   │
                         │ Dashboard          │
                         └─────────┬──────────┘
                                   │
                              ┌────▼────┐
                              │   SNS   │
                              └──┬───┬──┘
                                 │   │
                           Email │   │ Lambda
                                 │   │
                                 │   ▼
                                 │ Operational
                                 │ Incident Triage
                                 │
                                 └───────────────┐
                                                 │
                                         EC2 Incident Tags

# AWS Services and Tools Used

| Service / Tool      | Purpose                                      |
| ------------------- | -------------------------------------------- |
| Amazon VPC          | Network isolation and subnet segmentation    |
| Amazon EC2          | Development and Production workloads         |
| AWS Systems Manager | Secure administrative access without SSH     |
| Amazon CloudWatch   | Metrics, dashboards, and alarms              |
| CloudWatch Agent    | Custom disk and memory metrics               |
| Amazon SNS          | Alarm notification routing                   |
| AWS Lambda          | Automated incident classification and triage |
| AWS IAM             | Least-privilege workload permissions         |
| Amazon EBS          | Encrypted instance storage                   |
| GitHub Actions      | Terraform CI validation                      |
| Terraform           | Infrastructure as Code                       |

---

# Repository Structure

```text id="3xbyxk"
cloudguard-aws-monitoring-security/
├── .github/
│   └── workflows/
│       └── terraform-check.yml
│
├── cloudwatch-agent/
│   └── config.json.tftpl
│
├── docs/
│   ├── incident-report.md
│   ├── incident-response-runbook.md
│   ├── diagrams/
│   └── screenshots/
│
├── lambda/
│   └── operational_triage/
│       └── handler.py
│
├── terraform/
│   ├── user-data/
│   │   ├── dev.sh.tftpl
│   │   └── prod.sh.tftpl
│   ├── cloudwatch.tf
│   ├── data.tf
│   ├── ec2.tf
│   ├── iam.tf
│   ├── lambda.tf
│   ├── locals.tf
│   ├── networking.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── security-groups.tf
│   ├── sns.tf
│   ├── variables.tf
│   └── versions.tf
│
├── .gitignore
├── LICENSE
└── README.md
```

---

# Infrastructure Design

## Network Segmentation

CloudGuard uses a custom VPC with separate Development and Production subnets.

Example network layout:

```text id="h2osje"
10.20.0.0/16    CloudGuard VPC

10.20.1.0/24    Development subnet
10.20.2.0/24    Production subnet
```

The environments use separate:

* Subnets
* Route tables
* Availability Zones
* Security groups
* Environment tags

This design provides a foundation for stronger network isolation while keeping the lab architecture cost-conscious.

---

## Secure Administrative Access

The EC2 instances do not expose SSH access.

The environment uses no:

```text id="4nr6qe"
Port 22 ingress
SSH key pairs
Long-lived AWS credentials on EC2
```

Administrative access is performed using AWS Systems Manager Session Manager.

Each EC2 instance receives an IAM instance profile containing the permissions required for:

* AWS Systems Manager
* CloudWatch Agent

---

## EC2 Security Controls

The EC2 configuration includes:

* Amazon Linux 2023
* Encrypted `gp3` root volumes
* IMDSv2 required
* Separate Development and Production security groups
* No inbound security group rules
* IAM roles instead of static credentials

---

# Monitoring

## Native EC2 Metrics

Amazon CloudWatch provides native EC2 CPU utilization metrics.

The Development environment is monitored for sustained high CPU utilization.

### High CPU Alarm

```text id="37zu22"
Metric: CPUUtilization
Threshold: >= 85%
Period: 60 seconds
Evaluation periods: 2
Datapoints to alarm: 2
```

Alarm:

```text id="ut1evf"
cloudguard-dev-high-cpu
```

---

## Custom Host Metrics

The CloudWatch Agent collects:

```text id="739gbe"
disk_used_percent
mem_used_percent
```

Metrics are published under the following namespace:

```text id="t45hyn"
CWAgent
```

The EC2 Instance ID is included as a metric dimension so that alarms can reliably identify the affected server.

### Production Disk Alarm

```text id="kpdvvf"
Metric: disk_used_percent
Threshold: >= 80%
Period: 60 seconds
Evaluation periods: 2
Datapoints to alarm: 2
```

Alarm:

```text id="xf973w"
cloudguard-prod-low-disk
```

### Production Memory Alarm

```text id="rw1zaf"
Metric: mem_used_percent
Threshold: >= 85%
Period: 60 seconds
Evaluation periods: 2
Datapoints to alarm: 2
```

Alarm:

```text id="jphm30"
cloudguard-prod-high-memory
```

---

# Automated Incident Triage

CloudWatch alarms send notifications to Amazon SNS.

SNS distributes each event to:

```text id="jvn8ym"
Email subscriber
       +
Operational-triage Lambda
```

The Lambda extracts:

* Alarm name
* EC2 Instance ID
* Alarm state
* Issue type

It then adds incident metadata to the affected EC2 instance.

Example:

```text id="5jdx0i"
Issue=HighCPU
IncidentStatus=Open
IncidentSource=CloudWatch
AlarmName=cloudguard-dev-high-cpu
LastIncidentAt=<UTC timestamp>
```

When the CloudWatch alarm returns to `OK`, the Lambda updates:

```text id="zpg17f"
IncidentStatus=Resolved
```

The function performs automated triage rather than destructive remediation.

This design prevents automation from restarting services, deleting files, or rebooting production systems without operator approval.

---

# Incident Simulation

Two controlled infrastructure incidents were generated to validate the complete monitoring workflow.

## Test 1 — Development High CPU

CPU load was generated with:

```bash id="jhwa7a"
sudo stress-ng --cpu 2 --timeout 600s
```

Expected workflow:

```text id="6qt05c"
CPU utilization increases
        ↓
CloudWatch detects >= 85%
        ↓
Alarm enters ALARM state
        ↓
SNS notification
        ↓
Email notification
        ↓
Lambda invocation
        ↓
EC2 incident tags applied
```

After the workload stopped:

```text id="bn9xhp"
CPU utilization normalizes
        ↓
CloudWatch alarm returns to OK
        ↓
Lambda receives recovery event
        ↓
IncidentStatus=Resolved
```

---

## Test 2 — Production Disk Utilization

Disk pressure was generated using a temporary test file:

```bash id="bl8y1d"
sudo fallocate -l 4G /var/tmp/cloudguard-disk-test
```

Disk utilization was verified using:

```bash id="v4ohmo"
df -h /
```

The test triggered the following alarm:

```text id="h6ky9b"
cloudguard-prod-low-disk
```

After validation, the test file was removed:

```bash id="xywo39"
sudo rm -f /var/tmp/cloudguard-disk-test
```

Disk utilization returned below the configured threshold, and the alarm subsequently transitioned back to `OK`.

---

# Monitoring Dashboard

The Terraform deployment creates the following CloudWatch dashboard:

```text id="5o8pxi"
cloudguard-operations-dashboard
```

The dashboard displays:

* Development CPU utilization
* Production disk utilization
* Production memory utilization
* CloudGuard alarm status

---

# Incident Documentation

The project includes a completed operational incident report:

`docs/incident-report.md`

It also includes an operational incident-response runbook:

`docs/incident-response-runbook.md`

These documents provide evidence of incident detection, investigation, response, recovery, and operational procedures.

---

# Infrastructure as Code

All AWS infrastructure is managed through Terraform.

Example deployment workflow:

```bash id="s07snq"
cd terraform

terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
```

Resources can be destroyed after testing using:

```bash id="f7s89m"
terraform destroy
```

---

# CI/CD Validation

GitHub Actions automatically validates Terraform changes on pushes and pull requests to `main`.

The workflow performs:

```bash id="xxzqx4"
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

Using `terraform init -backend=false` allows the CI workflow to initialize providers and modules without connecting to the Terraform state backend.

This helps catch Terraform syntax, configuration, and formatting problems before infrastructure changes are applied.

---

# Security Principles

The project follows several AWS security best practices.

## IAM Roles Instead of Static Credentials

EC2 and Lambda workloads use IAM roles rather than embedded or long-lived AWS access keys.

## Least Privilege

The operational-triage Lambda is granted only the EC2 permissions required by the incident-triage workflow.

## No SSH Exposure

Administrative access is performed through AWS Systems Manager Session Manager instead of exposing SSH to the network.

## IMDSv2

EC2 instances require Instance Metadata Service Version 2.

## Encryption

EC2 root EBS volumes are encrypted.

## Safe Automation

The Lambda performs incident classification and tagging rather than potentially destructive remediation.

---

# Screenshots

Implementation evidence is stored under:

```text id="w7gfea"
docs/screenshots/
```

Examples include:

* Terraform network deployment
* VPC resource map
* Development and Production EC2 instances
* Systems Manager managed nodes
* CloudWatch Agent metrics
* Operations dashboard
* CloudWatch alarms
* Lambda event processing
* High CPU incident
* Production low-disk incident
* GitHub Actions Terraform validation

---

# GuardDuty Extension

The original architecture included the following security-event workflow:

```text id="0vi0e9"
Amazon GuardDuty
        ↓
Amazon EventBridge
        ↓
Security Response Lambda
        ↓
Amazon SNS
```

GuardDuty was not deployed in the current lab environment because it was unavailable under the AWS account plan used for this implementation.

Rather than changing the account solely for this demonstration, GuardDuty was excluded from the deployed architecture.

A future version could add:

* Amazon GuardDuty
* EventBridge finding routing
* Security-response Lambda
* AWS Security Hub
* Automated isolation workflows

---

# Future Improvements

Potential enhancements include:

* SSM Automation remediation runbooks
* Systems Manager OpsCenter integration
* DynamoDB incident history
* Slack or Microsoft Teams notifications
* AWS Config compliance rules
* AWS Security Hub integration
* GuardDuty threat detection
* Multi-account Development and Production architecture
* Centralized CloudWatch Logs
* Automated diagnostic collection
* Approval-based Production remediation
* Remote Terraform state using Amazon S3
* Terraform state locking

---

# Cost Considerations

This project is designed as a short-lived learning environment.

Potential AWS charges can include:

* EC2 instances
* EBS volumes
* Public IPv4 addresses
* CloudWatch custom metrics
* Detailed monitoring
* CloudWatch alarms
* Lambda invocations
* SNS notifications

Instances should be stopped during extended periods when the environment is not being used.

When testing is complete, the environment can be removed using:

```bash id="xi3mgf"
terraform destroy
```

---

# Key Lessons

This project demonstrates that effective cloud operations require more than simply provisioning infrastructure.

The implementation combines:

```text id="au4bhh"
Infrastructure as Code
        +
Monitoring
        +
Event-driven automation
        +
Security controls
        +
Incident response
        +
Operational documentation
```

The result is a reproducible AWS monitoring platform capable of detecting infrastructure problems, notifying operators, identifying affected resources, and automatically tracking incident state from detection through recovery.

---

# Author

**Artem Saitov**

Cloud / DevOps Engineering Portfolio Project
