# Disk autoexpand Terraform modules deployment order

1. `IAM roles first`
- Parser Lambda execution role
- CalculateDiskSize Lambda execution role
- Step Functions execution role
  These are foundations. Lambdas need their IAM roles before they can be created, and Step Functions also needs its execution role.
2. `CalculateDiskSize Lambda`
- It only depends on its Lambda IAM role.
- Step Functions later needs this Lambda ARN.
3. `Step Functions`
- Depends on the Step Functions IAM role.
- Depends on the CalculateDiskSize Lambda ARN.
- Its definition still references the future target role name DiskAutoExpandSpokeRole, but that role does not have to exist in Central Server
4. `Parser Lambda`
- Depends on its Lambda IAM role.

- Depends on the Step Functions ARN because you inject:
```text
STATE_MACHINE_ARN
```
- Its IAM policy also grants states:StartExecution against that state machine.
5. `API Gateway`
- Depends on the Parser Lambda because its integration points to that Lambda.
- Also creates the Lambda permission allowing API Gateway to invoke the parser.
6. `Dynatrace workflow last`
- Once API Gateway exists, you get the actual API endpoint.
- Then the Dynatrace HTTP action can POST to:
```text
https://<api-id>.execute-api.us-east-1.amazonaws.com/disk-autoexpand
```


## Final result reporting to Slack

The existing POST `/disk-autoexpand` endpoint now accepts two request types:

- Existing expansion payloads (or `"action": "start"`) start an execution as before.
- `{"action":"status","executionArn":"arn:aws:states:REGION:ACCOUNT:execution:disk-autoexpand:NAME"}` reads an execution. This request never starts or changes an expansion.

Status responses contain `success` (the API request succeeded), `executionArn`,
`status`, `terminal`, `error`, and `cause`. An AWS `FAILED` execution still returns
HTTP 200 with `success: true`; use `status` to determine the expansion outcome.
The parser rejects ARNs outside its configured state machine, and its IAM policy
scopes DescribeExecution to executions of that machine.

The Dynatrace workflow retains the existing start task, then:

1. Waits 30 seconds before polling. Each attempt performs one status request.
2. Retries pending results or transient status errors up to 59 times, with a
   30-second delay (60 total attempts). The task timeout is 2,100 seconds.
   This is roughly 30 minutes with fast responses, capped at 35 minutes;
   each HTTP status request has a 15-second timeout.
3. Runs `prepare_result` even when polling fails or is skipped. It uses a terminal
   polling result or makes one final status request. Still-pending AWS executions
   produce MONITORING_TIMEOUT; unavailable status produces MONITORING_ERROR.
   Neither means AWS failed, and neither cancels AWS. A missing start confirmation
   produces START_UNCONFIRMED; inspect AWS before retrying the start request.
4. Sends host, instance, drive, account, region, and outcome to Slack.
   The execution ARN remains available in task results for troubleshooting. SUCCEEDED, FAILED, TIMED_OUT, and ABORTED are reported distinctly.
5. Marks the final outcome task failed for any outcome other than SUCCEEDED,
   after the Slack task has been attempted.
