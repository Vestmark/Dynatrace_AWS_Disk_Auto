output "api_gateway_endpoint" {
  description = "Base endpoint of the disk auto-expansion HTTP API."
  value       = aws_apigatewayv2_api.disk_autoexpand.api_endpoint
}


output "disk_autoexpand_endpoint" {
  description = "Full POST endpoint used by the Dynatrace workflow."
  value       = "${aws_apigatewayv2_api.disk_autoexpand.api_endpoint}/disk-autoexpand"
}


output "parser_lambda_name" {
  description = "Name of the Dynatrace disk alert parser Lambda."
  value       = aws_lambda_function.parser.function_name
}


output "calculate_lambda_name" {
  description = "Name of the disk size calculation Lambda."
  value       = aws_lambda_function.calculate.function_name
}


output "state_machine_arn" {
  description = "ARN of the disk auto-expansion Step Functions state machine."
  value       = aws_sfn_state_machine.disk_autoexpand.arn
}


output "step_functions_role_arn" {
  description = "ARN of the Test-D Step Functions execution role. Target-account spoke roles must trust this ARN."
  value       = aws_iam_role.step_functions.arn
}