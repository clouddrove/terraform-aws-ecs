data "aws_caller_identity" "current" {}

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
  attributes  = compact(concat(var.attributes, ["service"]))
  label_order = var.label_order
}

resource "aws_ecs_service" "default" {
  count                              = local.ec2_enabled || local.fargate_enabled ? 1 : 0
  name                               = module.labels.id
  cluster                            = var.cluster_name
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = "arn:aws:iam::${data.aws_caller_identity/current.account_id}:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  launch_type                        = var.launch_type
  propagate_tags                     = var.propagate_tags
  scheduling_strategy                = var.scheduling_strategy
  task_definition                    = var.task_definition
  
  tags = module.labels.tags

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider
    weight            = var.weight
    base              = var.base
  }

  deployment_controller {
    type = var.type
  }

  load_balancer {
    elb_name         = var.elb_name
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port

  }

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }
}