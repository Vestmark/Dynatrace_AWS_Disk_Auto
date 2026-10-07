variable "environment" {
  description = "Environment name used in resource naming."
  type        = string
}

variable "step_functions_role_arn" {
  description = "Execution role ARN from the IAM module."
  type        = string
}

variable "step_functions_role_name" {
  description = "Execution role name from the IAM module, for inline policies."
  type        = string
}

variable "calculate_lambda_arn" {
  description = "Function ARN from the calculate-lambda module."
  type        = string
}

variable "spoke_role_name" {
  description = "Role to assume in target accounts."
  type        = string
  default     = "DiskAutoExpandSpokeRole"
}
