output "parser_lambda_role_arn" {
  value = aws_iam_role.parser_lambda.arn
}

output "parser_lambda_role_name" {
  value = aws_iam_role.parser_lambda.name
}

output "calculate_lambda_role_arn" {
  value = aws_iam_role.calculate_lambda.arn
}

output "step_functions_role_arn" {
  description = "Target-account spoke roles must trust this ARN."
  value       = aws_iam_role.step_functions.arn
}

output "step_functions_role_name" {
  value = aws_iam_role.step_functions.name
}
