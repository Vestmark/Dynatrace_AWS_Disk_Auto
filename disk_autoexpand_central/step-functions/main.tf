locals {
  common_tags = {
    Project     = "DiskAutoExpansion"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "step_functions_invoke_lambda" {
  name = "InvokeCalculateDiskSize"
  role = var.step_functions_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["lambda:InvokeFunction"]
      Resource = var.calculate_lambda_arn
    }]
  })
}

resource "aws_iam_role_policy" "step_functions_assume_spoke" {
  name = "AssumeDiskAutoExpandSpokeRole"
  role = var.step_functions_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sts:AssumeRole"]
      Resource = "arn:aws:iam::*:role/${var.spoke_role_name}"
    }]
  })
}

resource "aws_sfn_state_machine" "disk_autoexpand" {
  name     = "disk-autoexpand-${var.environment}"
  role_arn = var.step_functions_role_arn
  definition = templatefile("${path.module}/disk_auto_expand.asl.json", {
    calculate_lambda_arn = var.calculate_lambda_arn
    spoke_role_name      = var.spoke_role_name
  })
  depends_on = [
    aws_iam_role_policy.step_functions_invoke_lambda,
    aws_iam_role_policy.step_functions_assume_spoke,
  ]
  tags = local.common_tags
}
