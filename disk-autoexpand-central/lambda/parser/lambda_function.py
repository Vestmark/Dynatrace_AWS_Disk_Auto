import json
import os
import time
import boto3

sfn = boto3.client("stepfunctions")

STATE_MACHINE_ARN = os.environ["STATE_MACHINE_ARN"]
DEFAULT_EXPAND_PERCENT = int(os.environ.get("EXPAND_PERCENT", "15"))


def validate_api_payload(body):
    required = ["accountId", "instanceId", "region", "drive"]

    missing = [
        key for key in required
        if not body.get(key)
    ]

    if missing:
        raise ValueError(
            f"Missing required field(s): {', '.join(missing)}"
        )

    account_id = str(body["accountId"])

    if len(account_id) != 12 or not account_id.isdigit():
        raise ValueError(
            f"Invalid AWS account ID: {account_id}"
        )

    instance_id = body["instanceId"]

    if not instance_id.startswith("i-"):
        raise ValueError(
            f"Invalid EC2 instance ID: {instance_id}"
        )

    drive = body["drive"]

    if len(drive) != 2 or drive[1] != ":":
        raise ValueError(
            f"Invalid Windows drive format: {drive}"
        )


def build_step_function_payload(body):
    validate_api_payload(body)

    return {
        "AccountId": str(body["accountId"]),
        "Region": body["region"],
        "InstanceId": body["instanceId"],
        "DriveLetter": body["drive"],
        "ExpandPercent": DEFAULT_EXPAND_PERCENT
    }


def build_execution_name(payload):
    drive = payload["DriveLetter"].replace(":", "")

    name = (
        f"disk-autoexpand-"
        f"{payload['AccountId']}-"
        f"{payload['InstanceId']}-"
        f"{drive}-"
        f"{int(time.time())}"
    )

    return name[:80]


def start_state_machine(payload):
    response = sfn.start_execution(
        stateMachineArn=STATE_MACHINE_ARN,
        name=build_execution_name(payload),
        input=json.dumps(payload)
    )

    print("Started Step Functions execution:")
    print(json.dumps(response, default=str))

    return response


def lambda_handler(event, context):
    print("=== Raw API Gateway Event ===")
    print(json.dumps(event, default=str))

    try:
        body = event.get("body", event)

        if isinstance(body, str):
            body = json.loads(body)

        if not isinstance(body, dict):
            raise ValueError(
                "Request body must be a JSON object."
            )

        step_function_payload = build_step_function_payload(body)

        response = start_state_machine(step_function_payload)

        return {
            "statusCode": 200,
            "headers": {
                "content-type": "application/json"
            },
            "body": json.dumps({
                "success": True,
                "message": "Disk auto-expansion state machine started",
                "executionArn": response["executionArn"],
                "accountId": body.get("accountId"),
                "instanceId": body.get("instanceId"),
                "drive": body.get("drive"),
                "host": body.get("host"),
                "eventId": body.get("eventId"),
                "expandPercent": DEFAULT_EXPAND_PERCENT
            })
        }

    except ValueError as error:
        print(f"Validation error: {error}")

        return {
            "statusCode": 400,
            "headers": {
                "content-type": "application/json"
            },
            "body": json.dumps({
                "success": False,
                "error": str(error)
            })
        }

    except Exception as error:
        print(f"Unhandled error: {error}")

        return {
            "statusCode": 500,
            "headers": {
                "content-type": "application/json"
            },
            "body": json.dumps({
                "success": False,
                "error": str(error)
            })
        }