############################################
# Package CalculateDiskSize Lambda
############################################

data "archive_file" "calculate_disk_size" {
  type        = "zip"
  source_file = "${path.module}/lambda/calculate/lambda_function.py"
  output_path = "${path.module}/lambda/calculate/calculate_disk_size.zip"
}


############################################
# CalculateDiskSize Lambda
############################################

resource "aws_lambda_function" "calculate" {
  function_name = "CalculateDiskSize-${var.environment}"

  role    = aws_iam_role.calculate_lambda.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.13"

  filename         = data.archive_file.calculate_disk_size.output_path
  source_code_hash = data.archive_file.calculate_disk_size.output_base64sha256

  tags = local.common_tags
}


############################################
# Package Parser Lambda
############################################

data "archive_file" "parser" {
  type        = "zip"
  source_file = "${path.module}/lambda/parser/lambda_function.py"
  output_path = "${path.module}/lambda/parser/parser.zip"
}


############################################
# Parser Lambda
############################################

resource "aws_lambda_function" "parser" {
  function_name = "ParseDynatraceDiskAlertAndStartExpansion-${var.environment}"

  role    = aws_iam_role.parser_lambda.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.13"

  filename         = data.archive_file.parser.output_path
  source_code_hash = data.archive_file.parser.output_base64sha256

  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.disk_autoexpand.arn
      EXPAND_PERCENT    = tostring(var.expand_percent)
    }
  }

  tags = local.common_tags
}


############################################
# Parser Lambda -> Step Functions
############################################

resource "aws_iam_role_policy" "parser_start_state_machine" {
  name = "StartDiskAutoExpandStateMachine"
  role = aws_iam_role.parser_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "states:StartExecution"
      ]

      Resource = aws_sfn_state_machine.disk_autoexpand.arn
    }]
  })
}