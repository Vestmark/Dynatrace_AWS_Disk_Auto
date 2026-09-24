terraform {
  source = "git::https://github.com/Vestmark/Dynatrace_AWS_Disk_Auto.git//disk_autoexpand_central/step-functions?ref=ec7a96df40b245474f87c1b0474e0498956c70b0"
}

include {
  path = find_in_parent_folders()
}

dependency "iam" {
  config_path = "../iam"
  mock_outputs = {
    step_functions_role_arn  = "arn:aws:iam::123456789012:role/disk-autoexpand-stepfunctions-plan-only"
    step_functions_role_name = "disk-autoexpand-stepfunctions-plan-only"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "calculate_lambda" {
  config_path = "../calculate-lambda"
  mock_outputs = {
    calculate_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:CalculateDiskSize-plan-only"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  environment              = get_env("TF_VAR_environment")
  step_functions_role_arn  = dependency.iam.outputs.step_functions_role_arn
  step_functions_role_name = dependency.iam.outputs.step_functions_role_name
  calculate_lambda_arn     = dependency.calculate_lambda.outputs.calculate_lambda_arn
}
