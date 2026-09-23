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
