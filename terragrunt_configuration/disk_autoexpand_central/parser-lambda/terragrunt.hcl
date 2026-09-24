terraform {
  source = "git::https://github.com/Vestmark/Dynatrace_AWS_Disk_Auto.git//disk_autoexpand_central/parser-lambda?ref=ec7a96df40b245474f87c1b0474e0498956c70b0"
}

include {
  path = find_in_parent_folders()
}

dependency "iam" {
  config_path = "../iam"
  mock_outputs = {
    parser_lambda_role_arn  = "arn:aws:iam::123456789012:role/disk-autoexpand-parser-plan-only"
    parser_lambda_role_name = "disk-autoexpand-parser-plan-only"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "step_functions" {
  config_path = "../step-functions"
  mock_outputs = {
    state_machine_arn = "arn:aws:states:us-east-1:123456789012:stateMachine:disk-autoexpand-plan-only"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  environment             = get_env("TF_VAR_environment")
  parser_lambda_role_arn  = dependency.iam.outputs.parser_lambda_role_arn
  parser_lambda_role_name = dependency.iam.outputs.parser_lambda_role_name
  state_machine_arn       = dependency.step_functions.outputs.state_machine_arn
}
