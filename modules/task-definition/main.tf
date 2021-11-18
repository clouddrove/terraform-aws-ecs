locals {
  ec2_enabled     = var.enabled && var.ec2_td_enabled ? true : false
  fargate_enabled = var.enabled && var.fargate_td_enabled ? true : false
}

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "0.15.0"
  name    = var.name
  //application = var.application
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  attributes  = compact(concat(var.attributes, ["task-definition"]))
  label_order = var.label_order
}

#Module      : IAM ROLE
#Description : IAM Role for for ECS Task Definition.
module "iam-role-td" {
  source             = "clouddrove/iam-role/aws"
  version            = "0.15.0"
  name               = format("%s-td", var.name)
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

#Module      : ECS TASK DEFINITION
#Description : ECS task definition to deploy on EC2.
resource "aws_ecs_task_definition" "ec2" {
  count                    = local.ec2_enabled ? 1 : 0
  family                   = module.labels.id
  container_definitions    = file(var.file_name)
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

#Module      : CLOUD WATCH LOG GROUP
#Description : Cloud watch log group for container logs.
resource "aws_cloudwatch_log_group" "ec2-container" {
  count             = local.ec2_enabled ? 1 : 0
  name              = var.container_log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}

#Module      : ECS TASK DEFINITION
#Description : ECS task definition to deploy on Fargate.
resource "aws_ecs_task_definition" "fargate" {
  count                    = local.fargate_enabled ? 1 : 0
  family                   = module.labels.id
  container_definitions    = file(var.file_name)
  task_role_arn            = var.task_role_arn
  execution_role_arn       = module.iam-role-td.arn
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  requires_compatibilities = ["FARGATE"]
  tags                     = module.labels.tags
}

#Module      : CLOUD WATCH LOG GROUP
#Description : Cloud watch log group for container logs.
resource "aws_cloudwatch_log_group" "fargate-container" {
  count             = local.fargate_enabled ? 1 : 0
  name              = var.container_log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = module.labels.tags
}