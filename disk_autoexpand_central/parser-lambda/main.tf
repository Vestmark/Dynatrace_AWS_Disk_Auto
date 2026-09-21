locals {
  common_tags = {
    Project     = "DiskAutoExpansion"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "archive_file" "parser" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/parser.zip"
}

resource "aws_iam_role_policy" "parser_start_state_machine" {
  name = "StartDiskAutoExpandStateMachine"
  role = var.parser_lambda_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["states:StartExecution"]
      Resource = var.state_machine_arn
    }]
  })
}

resource "aws_lambda_function" "parser" {
  function_name    = "ParseDynatraceDiskAlertAndStartExpansion-${var.environment}"
  role             = var.parser_lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  filename         = data.archive_file.parser.output_path
  source_code_hash = data.archive_file.parser.output_base64sha256
  environment {
    variables = {
      STATE_MACHINE_ARN = var.state_machine_arn
      EXPAND_PERCENT    = tostring(var.expand_percent)
    }
  }
  depends_on = [aws_iam_role_policy.parser_start_state_machine]
  tags       = local.common_tags
}
