variable "environment" {
  description = "Environment name used in resource naming."
  type        = string
}

variable "parser_lambda_role_arn" {
  description = "Execution role ARN from the IAM module."
  type        = string
}

variable "parser_lambda_role_name" {
  description = "Execution role name from the IAM module, for its inline policy."
  type        = string
}

variable "state_machine_arn" {
  description = "State machine ARN from the step-functions module."
  type        = string
}

variable "expand_percent" {
  description = "Percentage by which an EBS volume is expanded."
  type        = number
  default     = 15
}
