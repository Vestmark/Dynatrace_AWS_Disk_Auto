locals {
  common_tags = {
    Project     = "DiskAutoExpansion"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "archive_file" "calculate_disk_size" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/calculate_disk_size.zip"
}

resource "aws_lambda_function" "calculate" {
  function_name    = "CalculateDiskSize"
  role             = var.calculate_lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  filename         = data.archive_file.calculate_disk_size.output_path
  source_code_hash = data.archive_file.calculate_disk_size.output_base64sha256
  tags             = local.common_tags
}
