import json
import logging
from datetime import datetime, timezone
from typing import Any

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client("ec2")


def get_instance_id(alarm_message: dict[str, Any]) -> str | None:
    """Extract the EC2 instance ID from CloudWatch alarm dimensions."""
    dimensions = alarm_message.get("Trigger", {}).get("Dimensions", [])

    for dimension in dimensions:
        if dimension.get("name") == "InstanceId":
            return dimension.get("value")

    return None


def get_issue_type(alarm_name: str) -> str:
    """Map CloudWatch alarm names to operational issue types."""
    normalized_name = alarm_name.lower()

    if "high-cpu" in normalized_name:
        return "HighCPU"

    if "low-disk" in normalized_name:
        return "LowDisk"

    if "high-memory" in normalized_name:
        return "HighMemory"

    return "Unknown"


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    logger.info("Received event: %s", json.dumps(event))

    records = event.get("Records", [])

    if not records:
        raise ValueError("SNS event contains no records")

    processed_incidents = []

    for record in records:
        sns_message = record.get("Sns", {}).get("Message")

        if not sns_message:
            logger.warning("Skipping record without an SNS message")
            continue

        alarm_message = json.loads(sns_message)

        alarm_name = alarm_message.get("AlarmName", "UnknownAlarm")
        new_state = alarm_message.get("NewStateValue", "UNKNOWN")
        instance_id = get_instance_id(alarm_message)

        if not instance_id:
            logger.error(
                "No InstanceId dimension found for alarm %s",
                alarm_name,
            )
            continue

        issue_type = get_issue_type(alarm_name)
        incident_status = "Open" if new_state == "ALARM" else "Resolved"
        incident_time = datetime.now(timezone.utc).isoformat()

        tags = [
            {"Key": "Issue", "Value": issue_type},
            {"Key": "IncidentStatus", "Value": incident_status},
            {"Key": "IncidentSource", "Value": "CloudWatch"},
            {"Key": "AlarmName", "Value": alarm_name},
            {"Key": "LastIncidentAt", "Value": incident_time},
        ]

        ec2.create_tags(
            Resources=[instance_id],
            Tags=tags,
        )

        incident_record = {
            "alarm_name": alarm_name,
            "instance_id": instance_id,
            "issue_type": issue_type,
            "alarm_state": new_state,
            "incident_status": incident_status,
            "incident_time": incident_time,
        }

        logger.info("Processed incident: %s", json.dumps(incident_record))
        processed_incidents.append(incident_record)

    return {
        "statusCode": 200,
        "processedIncidents": processed_incidents,
    }