############################################
# Disk Auto Expansion State Machine
############################################

resource "aws_sfn_state_machine" "disk_autoexpand" {
  name     = "disk-autoexpand-${var.environment}"
  role_arn = aws_iam_role.step_functions.arn

  definition = templatefile(
    "${path.module}/stepfunction/disk_auto_expand.asl.json",
    {
      calculate_lambda_arn = aws_lambda_function.calculate.arn
      spoke_role_name      = var.spoke_role_name
    }
  )

  tags = local.common_tags
}


############################################
# Step Functions -> CalculateDiskSize Lambda
############################################

resource "aws_iam_role_policy" "step_functions_invoke_lambda" {
  name = "InvokeCalculateDiskSize"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "lambda:InvokeFunction"
      ]

      Resource = aws_lambda_function.calculate.arn
    }]
  })
}


############################################
# Step Functions -> Target Account Spoke Role
############################################

resource "aws_iam_role_policy" "step_functions_assume_spoke" {
  name = "AssumeDiskAutoExpandSpokeRole"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "sts:AssumeRole"
      ]

      Resource = "arn:aws:iam::*:role/${var.spoke_role_name}"
    }]
  })
}