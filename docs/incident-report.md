# CloudGuard Operational Incident Report

## Incident Summary

CloudGuard's monitoring platform detected two controlled infrastructure incidents during validation testing:

1. High CPU utilization on the Development EC2 instance
2. High disk utilization on the Production EC2 instance

Both incidents were detected by Amazon CloudWatch, routed through Amazon SNS, and processed by the CloudGuard operational-triage Lambda function.

The Lambda automatically classified the incidents and added operational tags to the affected EC2 instances.

No customer-facing impact occurred because both events were intentionally generated as controlled tests.

---

# Incident 1 — Development High CPU

## Incident ID

CG-OPS-001

## Environment

Development

## Detection Source

Amazon CloudWatch

## Alarm

`cloudguard-dev-high-cpu`

## Severity

Medium

## Condition

CPU utilization remained at or above 85% for two consecutive one-minute evaluation periods.

## Trigger

The following controlled workload was executed on the Development EC2 instance:

```bash
sudo stress-ng --cpu 2 --timeout 600s

Detection

The CloudWatch alarm transitioned from:

OK → ALARM

Amazon SNS distributed the alert to:

Email notification subscriber
CloudGuard operational-triage Lambda
Automated Triage

The Lambda identified the affected EC2 instance and added the following tags:

Issue=HighCPU
IncidentStatus=Open
IncidentSource=CloudWatch
AlarmName=cloudguard-dev-high-cpu
LastIncidentAt=<UTC timestamp>
Investigation

The high CPU condition was confirmed to originate from the controlled stress-ng process.

No unexpected processes or unauthorized activity were identified.

Resolution

The stress-ng workload automatically terminated after the configured timeout.

CPU utilization returned to normal levels.

CloudWatch subsequently transitioned the alarm:

ALARM → OK

The operational-triage Lambda processed the recovery event and updated:

IncidentStatus=Resolved
Business Impact

None.

The incident occurred in the Development environment as part of an approved monitoring validation exercise.

Incident 2 — Production High Disk Utilization
Incident ID

CG-OPS-002

Environment

Production

Detection Source

Amazon CloudWatch Agent

Alarm

cloudguard-prod-low-disk

Severity

Medium

Condition

Root filesystem utilization remained at or above 80% for two consecutive one-minute evaluation periods.

Trigger

A controlled test file was created:

sudo fallocate -l 4G /var/tmp/cloudguard-disk-test

If required during testing, the file size was increased while monitoring remaining disk capacity.

Detection

The CloudWatch Agent published the disk_used_percent custom metric.

The CloudWatch alarm transitioned:

OK → ALARM

Amazon SNS delivered the incident notification and invoked the operational-triage Lambda.

Automated Triage

The Production EC2 instance received:

Issue=LowDisk
IncidentStatus=Open
IncidentSource=CloudWatch
AlarmName=cloudguard-prod-low-disk
LastIncidentAt=<UTC timestamp>
Investigation

Disk usage was inspected with:

df -h /

The increased disk utilization was confirmed to originate from the controlled test file.

No unexpected filesystem growth was identified.

Resolution

The test file was removed:

sudo rm -f /var/tmp/cloudguard-disk-test

Disk utilization returned below the configured threshold.

CloudWatch transitioned:

ALARM → OK

The Lambda then updated:

IncidentStatus=Resolved
Business Impact

None.

The Production incident was intentionally generated as part of a controlled monitoring test.

Root Cause Analysis

Both incidents were intentionally generated during CloudGuard monitoring validation.

The objective was to confirm that the monitoring platform could:

Detect infrastructure degradation
Notify operators
Invoke automated event-processing workflows
Identify the affected resource
Classify the incident
Track incident state
Detect recovery
Actions Taken

The CloudGuard monitoring workflow successfully:

Collected EC2 and host-level metrics
Evaluated CloudWatch thresholds
Generated CloudWatch alarms
Routed events through SNS
Delivered email notifications
Invoked the operational-triage Lambda
Tagged affected EC2 instances
Logged structured incident information
Detected recovery
Updated incident status to resolved
Preventive and Future Improvements

Future versions of CloudGuard could include:

SSM Automation runbooks for controlled remediation
Automatic collection of diagnostic information
Systems Manager OpsCenter incident creation
Slack or Microsoft Teams notifications
Centralized incident storage in DynamoDB
AWS Config compliance monitoring
AWS Security Hub integration
GuardDuty threat detection
EventBridge-driven security response
Multi-account Development and Production isolation

GuardDuty was intentionally excluded from the current implementation because it was unavailable under the AWS account plan used for this lab.

Lessons Learned
Detection before remediation

Automated systems should first identify and classify incidents reliably before performing disruptive remediation.

Least privilege

Lambda permissions were restricted to the EC2 resources and actions required by the workflow.

Controlled automation

Automatically rebooting instances or deleting files could cause additional production impact. The current implementation therefore performs automated triage while leaving potentially disruptive remediation actions under operator control.

Monitoring recovery matters

A monitoring system should track both incident detection and recovery. CloudGuard processes both ALARM and OK state transitions.

Infrastructure as Code

Terraform ensures that CloudGuard monitoring infrastructure can be recreated consistently and reviewed through version control.


## Important adjustment

Where it says:

```bash
sudo fallocate -l 4G /var/tmp/cloudguard-disk-test

change 4G to the actual size you used if you ended up using 5 GB.

Do not claim something different from your real test.