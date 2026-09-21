output "parser_lambda_name" {
  value = aws_lambda_function.parser.function_name
}

output "parser_lambda_invoke_arn" {
  value = aws_lambda_function.parser.invoke_arn
}
