resource "aws_iam_role" "apigw_role" {
  name = "${local.name_prefix}-apigw-role"
assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "apigateway.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "apigw_policy" {
  role = aws_iam_role.apigw_role.id
policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action   = ["events:PutEvents"],
      Effect   = "Allow",
      Resource = aws_cloudwatch_event_bus.custom_bus.arn
    }]
  })
}
