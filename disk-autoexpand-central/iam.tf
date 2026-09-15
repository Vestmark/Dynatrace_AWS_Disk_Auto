############################################
# Parser Lambda Execution Role
############################################

resource "aws_iam_role" "parser_lambda" {
  name = "${local.project_name}-parser-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}


resource "aws_iam_role_policy_attachment" "parser_lambda_basic" {
  role       = aws_iam_role.parser_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


############################################
# CalculateDiskSize Lambda Execution Role
############################################

resource "aws_iam_role" "calculate_lambda" {
  name = "${local.project_name}-calculate-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}


resource "aws_iam_role_policy_attachment" "calculate_lambda_basic" {
  role       = aws_iam_role.calculate_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


############################################
# Step Functions Execution Role
############################################

resource "aws_iam_role" "step_functions" {
  name = "${local.project_name}-stepfunctions-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "states.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}