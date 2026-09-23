 Disk autoexpand Terraform modules

These are five independently deployed Terraform root modules. Each directory needs its own Terragrunt configuration and remote state key in the TestD Terragrunt repository. Deploy in this order:

1. `iam` — creates three execution roles. Outputs their names and ARNs.
2. `calculate-lambda` — needs `iam.calculate_lambda_role_arn`. Outputs the Lambda ARN.
3. `step-functions` — needs `iam.step_functions_role_arn`, `iam.step_functions_role_name`, and `calculate-lambda.calculate_lambda_arn`. Outputs the state machine ARN.
4. `parser-lambda` — needs `iam.parser_lambda_role_arn`, `iam.parser_lambda_role_name`, and `step-functions.state_machine_arn`. Outputs the parser Lambda name and invoke ARN.
5. `api-gateway` — needs `parser-lambda.parser_lambda_name` and `parser-lambda.parser_lambda_invoke_arn`. Outputs the API endpoint.

Set `environment` explicitly and identically in all five Terragrunt configurations. The AWS provider region and credentials must be supplied by the TestD deployment environment. Do not run these directories with local state for a real deployment. Pin each Terragrunt `terraform.source` to a reviewed Bitbucket tag or commit.

Do not apply a previous all-in-one deployment and these modules to the same AWS account/environment: they define the same resource names. If the previous root has already been applied, migrate the existing resources into the five new state files before applying them.

This split preserves the current infrastructure configuration. It does not create the cross-account spoke role; target accounts must have that role and trust the Step Functions role ARN output by `iam`.

# deployment order

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
