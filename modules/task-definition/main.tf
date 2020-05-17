locals {
  ec2_enabled     = var.enabled && var.ec2_td_enabled ? true : false
  fargate_enabled = var.enabled && var.fargate_td_enabled ? true : false
}

module "labels" {
  source      = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"
  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  attributes  = compact(concat(var.attributes, ["task-definition"]))
  label_order = var.label_order
}

module "iam-role-td" {
  source = "git::https://github.com/clouddrove/terraform-aws-iam-role.git?ref=tags/0.12.3"

  name               = format("%s-td", var.name)
  application        = var.application
  environment        = var.environment
  label_order        = var.label_order
  enabled            = var.enabled
  assume_role_policy = data.aws_iam_policy_document.assume_role_td.json

  policy_enabled = true
  policy_arn     = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "assume_role_td" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_ecs_task_definition" "ec2" {
  count                    = local.ec2_enabled ? 1 : 0
  family                   = module.labels.id
  container_definitions    = var.network_mode == "bridge" ? file("${path.module}/templates/td-ec2.json") : file("${path.module}/templates/td-ec2-awsvpc.json")
  task_role_arn            = var.task_role_arn
  execution_role_arn       = module.iam-role-td.arn
  network_mode             = var.network_mode
  ipc_mode                 = var.ipc_mode
  pid_mode                 = var.pid_mode
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["EC2"]
  tags                     = module.labels.tags
}

resource "aws_cloudwatch_log_group" "ec2-container" {
  count             = local.ec2_enabled ? 1 : 0
  name              = format("%s-ec2-container-logs", module.labels.id)
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

resource "aws_ecs_task_definition" "fargate" {
  count                    = local.fargate_enabled ? 1 : 0
  family                   = module.labels.id
  container_definitions    = file("${path.module}/templates/td-fargate.json")
  task_role_arn            = var.task_role_arn
  execution_role_arn       = module.iam-role-td.arn
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  tags                     = module.labels.tags
}

resource "aws_cloudwatch_log_group" "fargate-container" {
  count             = local.fargate_enabled ? 1 : 0
  name              = format("%s-fargate-container-logs", module.labels.id)
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}