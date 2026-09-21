output "api_gateway_endpoint" {
  value = aws_apigatewayv2_api.disk_autoexpand.api_endpoint
}

output "disk_autoexpand_endpoint" {
  value = "${aws_apigatewayv2_api.disk_autoexpand.api_endpoint}/disk-autoexpand"
}
