variable "environment" {
  description = "Environment name used in resource naming."
  type        = string
}

variable "parser_lambda_name" {
  description = "Function name from the parser-lambda module."
  type        = string
}

variable "parser_lambda_invoke_arn" {
  description = "Invoke ARN from the parser-lambda module."
  type        = string
}
