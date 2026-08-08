# CloudGuard Incident Response Runbook

## High CPU

### Detection

Alarm:

`cloudguard-dev-high-cpu`

Threshold:

CPU utilization >= 85%

### Investigation

Connect using AWS Systems Manager Session Manager.

```bash
uptime
top
ps aux --sort=-%cpu | head

# Response

1. Confirm whether the workload is expected.
2. Identify the process responsible for the high CPU utilization.
3. Review relevant application and system logs.
4. Stop only the confirmed problematic workload if it is safe to do so.
5. Escalate the incident if the condition continues or the root cause cannot be identified.
6. Confirm that CPU utilization returns to an acceptable level.
7. Confirm that the CloudWatch alarm transitions back to `OK`.

---

# High Disk Usage

## Detection

**Alarm:**

`cloudguard-prod-low-disk`

**Threshold:**

Root filesystem utilization greater than or equal to 80%.

## Investigation

Check current filesystem utilization:

```bash
df -h /
```

Identify the largest directories and files:

```bash
sudo du -x / -h 2>/dev/null | sort -h | tail -20
```

Determine which filesystem paths are consuming the available disk space.

Review whether the increased usage is caused by:

* Application data
* Log files
* Temporary files
* Package or system files
* Unexpected filesystem growth

## Response

1. Determine whether the disk growth is expected.
2. Identify the files, directories, logs, or application data responsible for the increased utilization.
3. Do not delete files without first confirming their purpose and impact.
4. Remove or archive only files that have been confirmed as safe to clean up.
5. Consider increasing the EBS volume capacity if the disk growth is legitimate and persistent.
6. Confirm that filesystem utilization falls below the configured threshold.
7. Confirm that the CloudWatch alarm transitions back to `OK`.

---

# Escalation

Escalate the incident when:

* The root cause cannot be identified
* Application availability or performance is affected
* Resource utilization continues to increase
* The incident may involve unauthorized or suspicious activity
* Remediation could cause production disruption
* Additional infrastructure changes or permissions are required
