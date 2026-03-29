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

resource "aws_wafv2_web_acl" "api_waf" {
  name  = "${local.name_prefix}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "api" {
  resource_arn = aws_api_gateway_stage.stage.arn
  web_acl_arn  = aws_wafv2_web_acl.api_waf.arn
}

resource "aws_cloudwatch_event_rule" "rule" {
  event_bus_name = aws_cloudwatch_event_bus.custom_bus.name
event_pattern = jsonencode({
    "source": ["custom.api"],
    "detail-type": ["customEvent"],
    "detail": {
      "type": ["important"]
    }
  })
}

resource "aws_cloudwatch_event_target" "sqs" {
  rule      = aws_cloudwatch_event_rule.rule.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.main_queue.arn
}

resource "aws_sqs_queue" "dlq" {
  name = "${local.name_prefix}-dlq"
}

resource "aws_sqs_queue" "main_queue" {
  name = "${local.name_prefix}-queue"
redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
}
