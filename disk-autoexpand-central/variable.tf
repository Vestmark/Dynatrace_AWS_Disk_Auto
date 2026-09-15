variable "environment" {
  description = "Environment name used in resource naming."
  type        = string
  default     = "review"
}

variable "expand_percent" {
  description = "Percentage by which an EBS volume is expanded."
  type        = number
  default     = 15
}

variable "spoke_role_name" {
  description = "IAM role assumed by the centralized Step Functions workflow in target accounts."
  type        = string
  default     = "DiskAutoExpandSpokeRole"
}