include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/Vestmark/Dynatrace_AWS_Disk_Auto.git//disk-autoexpand-spoke?ref=<COMMIT_ID>"
}

inputs = {
  central_stepfunctions_role_arn = "arn:aws:iam::<CENTRAL_SERVER_ACCOUNT_ID>:role/disk-autoexpand-stepfunctions"
}