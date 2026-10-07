output "spoke_role_arn" {
  description = "ARN of the DiskAutoExpandSpokeRole."
  value       = aws_iam_role.spoke.arn
}