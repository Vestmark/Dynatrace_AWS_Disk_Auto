variable "environment" {
  description = "Environment name used in resource naming."
  type        = string
}

variable "calculate_lambda_role_arn" {
  description = "Execution role ARN from the IAM module."
  type        = string
}
