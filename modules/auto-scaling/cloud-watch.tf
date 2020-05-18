#Module      : CLOUD WATCH LOG GROUP
#Description : Cloud watch log group for logs.
resource "aws_cloudwatch_log_group" "dmesg" {
  count             = local.autoscaling_enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/dmesg"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

#Module      : CLOUD WATCH LOG GROUP
#Description : Cloud watch log group for logs.
resource "aws_cloudwatch_log_group" "docker" {
  count             = local.autoscaling_enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/docker"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

#Module      : CLOUD WATCH LOG GROUP
#Description : Cloud watch log group for logs.
resource "aws_cloudwatch_log_group" "ecs-agent" {
  count             = local.autoscaling_enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/ecs/ecs-agent.log"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

#Module      : CLOUD WATCH LOG GROUP
#Description : Cloud watch log group for logs.
resource "aws_cloudwatch_log_group" "ecs-init" {
  count             = local.autoscaling_enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/ecs/ecs-init.log"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

#Module      : CLOUD WATCH LOG GROUP
#Description : Cloud watch log group for logs.
resource "aws_cloudwatch_log_group" "audit" {
  count             = local.autoscaling_enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/ecs/audit.log"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

#Module      : CLOUD WATCH LOG GROUP
#Description : Cloud watch log group for logs.
resource "aws_cloudwatch_log_group" "messages" {
  count             = local.autoscaling_enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/messages"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}