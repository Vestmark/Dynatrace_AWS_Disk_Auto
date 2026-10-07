locals {
  common_tags = {
    Project     = "DiskAutoExpansion"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_apigatewayv2_api" "disk_autoexpand" {
  name          = "DiskAutoExpand"
  protocol_type = "HTTP"
  tags          = local.common_tags
}

resource "aws_apigatewayv2_integration" "parser_lambda" {
  api_id                 = aws_apigatewayv2_api.disk_autoexpand.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.parser_lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "disk_autoexpand" {
  api_id    = aws_apigatewayv2_api.disk_autoexpand.id
  route_key = "POST /disk-autoexpand"
  target    = "integrations/${aws_apigatewayv2_integration.parser_lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.disk_autoexpand.id
  name        = "$default"
  auto_deploy = true
  tags        = local.common_tags
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.parser_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.disk_autoexpand.execution_arn}/*/*"
}
