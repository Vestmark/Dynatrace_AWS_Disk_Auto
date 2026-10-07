terraform {
  source = "git::https://github.com/Vestmark/Dynatrace_AWS_Disk_Auto.git//disk_autoexpand_central/iam?ref=ec7a96df40b245474f87c1b0474e0498956c70b0"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  environment = get_env("TF_VAR_environment")
}
