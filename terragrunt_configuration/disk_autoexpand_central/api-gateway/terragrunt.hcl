terraform {
  source = "git::https://github.com/Vestmark/Dynatrace_AWS_Disk_Auto.git//disk_autoexpand_central/api-gateway?ref=ec7a96df40b245474f87c1b0474e0498956c70b0"
}

include {
  path = find_in_parent_folders()
}

dependency "parser_lambda" {
  config_path = "../parser-lambda"
  mock_outputs = {
    parser_lambda_name       = "ParseDynatraceDiskAlertAndStartExpansion-plan-only"
    parser_lambda_invoke_arn = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:ParseDynatraceDiskAlertAndStartExpansion-plan-only/invocations"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  environment              = get_env("TF_VAR_environment")
  parser_lambda_name       = dependency.parser_lambda.outputs.parser_lambda_name
  parser_lambda_invoke_arn = dependency.parser_lambda.outputs.parser_lambda_invoke_arn
}
