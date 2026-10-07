output "calculate_lambda_arn" {
  value = aws_lambda_function.calculate.arn
}

output "calculate_lambda_name" {
  value = aws_lambda_function.calculate.function_name
}
