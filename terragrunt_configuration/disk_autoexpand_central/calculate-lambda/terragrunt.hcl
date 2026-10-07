terraform {
  source = "git::https://github.com/Vestmark/Dynatrace_AWS_Disk_Auto.git//disk_autoexpand_central/calculate-lambda?ref=ec7a96df40b245474f87c1b0474e0498956c70b0"
}

include {
  path = find_in_parent_folders()
}

dependency "iam" {
  config_path = "../iam"
  mock_outputs = {
    calculate_lambda_role_arn = "arn:aws:iam::123456789012:role/disk-autoexpand-calculate-plan-only"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  environment               = get_env("TF_VAR_environment")
  calculate_lambda_role_arn = dependency.iam.outputs.calculate_lambda_role_arn
}
