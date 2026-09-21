# Disk autoexpand Terraform modules

These are five independently deployed Terraform root modules. Each directory needs its own Terragrunt configuration and remote state key in the TestD Terragrunt repository. Deploy in this order:

1. `iam` — creates three execution roles. Outputs their names and ARNs.
2. `calculate-lambda` — needs `iam.calculate_lambda_role_arn`. Outputs the Lambda ARN.
3. `step-functions` — needs `iam.step_functions_role_arn`, `iam.step_functions_role_name`, and `calculate-lambda.calculate_lambda_arn`. Outputs the state machine ARN.
4. `parser-lambda` — needs `iam.parser_lambda_role_arn`, `iam.parser_lambda_role_name`, and `step-functions.state_machine_arn`. Outputs the parser Lambda name and invoke ARN.
5. `api-gateway` — needs `parser-lambda.parser_lambda_name` and `parser-lambda.parser_lambda_invoke_arn`. Outputs the API endpoint.

Set `environment` explicitly and identically in all five Terragrunt configurations. The AWS provider region and credentials must be supplied by the TestD deployment environment. Do not run these directories with local state for a real deployment. Pin each Terragrunt `terraform.source` to a reviewed Bitbucket tag or commit.

The original `disk-autoexpand-central` remains intact for reference. Do not apply both the original root and these modules to the same AWS account/environment: they define the same resource names. If the original root has already been applied, migrate the existing resources into the five new state files before applying them.

This split preserves the current infrastructure configuration. It does not create the cross-account spoke role; target accounts must have that role and trust the Step Functions role ARN output by `iam`.
