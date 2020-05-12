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

module "iam-role-ec2" {
  source = "git::https://github.com/clouddrove/terraform-aws-iam-role.git?ref=tags/0.12.3"

  name               = format("%s-lb", var.name)
  application        = var.application
  environment        = var.environment
  label_order        = var.label_order
  enabled            = local.ec2_enabled && var.network_mode == "bridge" ? true : false
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json

  policy_enabled = true
  policy_arn     = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_ecs_service" "ec2" {
  count                              = local.ec2_enabled ? 1 : 0
  name                               = module.labels.id
  cluster                            = var.ec2_cluster_name
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  iam_role                           = var.network_mode == "bridge" ? module.iam-role-ec2.arn : ""
  propagate_tags                     = var.propagate_tags
  scheduling_strategy                = var.scheduling_strategy
  task_definition                    = var.ec2_task_definition
  
  tags = module.labels.tags

  capacity_provider_strategy {
    capacity_provider = var.ec2_capacity_provider
    weight            = var.weight
    base              = var.base
  }

  deployment_controller {
    type = var.type
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

}

resource "aws_ecs_service" "fargate" {
  count                              = local.fargate_enabled ? 1 : 0
  name                               = module.labels.id
  cluster                            = var.fargate_cluster_name
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  launch_type                        = "FARGATE"
  platform_version                   = var.platform_version
  propagate_tags                     = var.propagate_tags
  scheduling_strategy                = var.scheduling_strategy
  task_definition                    = var.fargate_task_definition
  
  tags = module.labels.tags

  deployment_controller {
    type = var.type
  }

  load_balancer {
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