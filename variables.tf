variable "project" {
  default = "event-bridge-demo"
}
variable "environment" {
  default = "dev"
}
variable "region" {
  default = "eu-west-1"
}
locals {
  name_prefix = "${var.project}-${var.environment}"
common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
