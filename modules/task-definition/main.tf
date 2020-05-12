locals {
  ec2_enabled     = var.enabled && var.ec2_enabled ? true : false
  fargate_enabled = var.enabled && var.fargate_enabled ? true : false
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

resource "aws_ecs_task_definition" "ec2" {
  count                    = local.ec2_enabled ? 1 : 0
  family                   = module.labels.id
  container_definitions    = file("${path.module}/templates/td-ec2.json")
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  network_mode             = var.network_mode
  ipc_mode                 = var.ipc_mode
  pid_mode                 = var.pid_mode
  requires_compatibilities = ["EC2"]
  tags                     = module.labels.tags
}

resource "aws_ecs_task_definition" "fargate" {
  count                    = local.fargate_enabled ? 1 : 0
  family                   = module.labels.id
  container_definitions    = file("${path.module}/templates/td-fargate.json")
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  ipc_mode                 = var.ipc_mode
  pid_mode                 = var.pid_mode
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  tags                     = module.labels.tags
}