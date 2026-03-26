resource "aws_cloudwatch_event_bus" "custom_bus" {
  name = "${local.name_prefix}-bus"
}
resource "aws_api_gateway_integration" "eventbridge" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.post.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:${var.region}:events:action/PutEvents"
credentials = aws_iam_role.apigw_role.arn
request_templates = {
    "application/json" = <<EOF
{
  "Entries": [
    {
      "Source": "custom.api",
      "DetailType": "customEvent",
      "Detail": "$util.escapeJavaScript($input.body)",
      "EventBusName": "${aws_cloudwatch_event_bus.custom_bus.name}"
    }
  ]
}
EOF
  }
}
