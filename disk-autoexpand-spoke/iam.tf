resource "aws_iam_role" "spoke" {
  name = "DiskAutoExpandSpokeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        AWS = var.central_stepfunctions_role_arn
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "spoke" {
  name = "DiskAutoExpandPolicy"
  role = aws_iam_role.spoke.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EC2VolumeActions"
        Effect = "Allow"

        Action = [
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:ModifyVolume",
          "ec2:DescribeInstances"
        ]

        Resource = "*"
      },
      {
        Sid    = "SSMActions"
        Effect = "Allow"

        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations"
        ]

        Resource = "*"
      }
    ]
  })
}