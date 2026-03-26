resource "aws_api_gateway_model" "request_model" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  name        = "RequestModel"
content_type = "application/json"
schema = jsonencode({
    type = "object",
    required = ["type", "payload"],
    properties = {
      type = { type = "string" },
      payload = { type = "object" }
    }
  })
}
resource "aws_api_gateway_request_validator" "validator" {
  rest_api_id                 = aws_api_gateway_rest_api.api.id
  name                        = "validator"
  validate_request_body       = true
  validate_request_parameters = false
}
resource "aws_api_gateway_method" "post" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.resource.id
  http_method      = "POST"
  authorization    = "NONE"
  request_models = {
    "application/json" = aws_api_gateway_model.request_model.name
  }
  request_validator_id = aws_api_gateway_request_validator.validator.id
}
