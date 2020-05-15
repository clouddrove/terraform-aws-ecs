resource "aws_cloudwatch_log_group" "dmesg" {
  count             = var.enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/dmesg"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

resource "aws_cloudwatch_log_group" "docker" {
  count             = var.enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/docker"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

resource "aws_cloudwatch_log_group" "ecs-agent" {
  count             = var.enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/ecs/ecs-agent.log"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

resource "aws_cloudwatch_log_group" "ecs-init" {
  count             = var.enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/ecs/ecs-init.log"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

resource "aws_cloudwatch_log_group" "audit" {
  count             = var.enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/ecs/audit.log"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

resource "aws_cloudwatch_log_group" "messages" {
  count             = var.enabled ? 1 : 0
  name              = "${var.cloudwatch_prefix}/var/log/messages"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

resource "aws_cloudwatch_log_group" "ec2-container" {
  count             = var.enabled ? 1 : 0
  name              = "ec2-container-logs"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

resource "aws_cloudwatch_log_group" "fargate-container" {
  count             = var.enabled ? 1 : 0
  name              = "fargate-container-logs"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}