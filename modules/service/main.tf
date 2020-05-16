locals {
  ec2_enabled     = var.enabled && var.ec2_service_enabled ? true : false
  fargate_enabled = var.enabled && var.fargate_service_enabled ? true : false
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
  enabled            = var.enabled
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

module "lb" {
  source                     = "git::https://github.com/clouddrove/terraform-aws-alb.git?ref=tags/0.12.5"
  name                       = format("%s-alb", var.name)
  application                = var.application
  environment                = var.environment
  label_order                = var.label_order
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.security_groups
  subnets                    = var.lb_subnet
  enable_deletion_protection = false
  enable                     = var.enabled
  target_type                = var.target_type
  vpc_id                     = var.vpc_id
  target_group_protocol      = "HTTP"
  target_group_port          = 80
  http_enabled               = false
  https_enabled              = true
  https_port                 = 80
  target_id                  = []
  listener_type              = "forward"
  listener_protocol          = "HTTP"
  listener_ssl_policy        = ""
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
  launch_type                        = "EC2"
  iam_role                           = module.iam-role-ec2.arn
  propagate_tags                     = var.propagate_tags
  scheduling_strategy                = var.scheduling_strategy
  task_definition                    = var.ec2_task_definition
  
  tags = module.labels.tags

  deployment_controller {
    type = var.type
  }

  load_balancer {
    target_group_arn = module.lb.main_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  dynamic "network_configuration" {
    for_each = var.ec2_awsvpc_enabled ? [1] : []

    content {
      subnets          = var.subnets
      security_groups  = var.security_groups
      assign_public_ip = var.assign_public_ip
    }
  }

  depends_on = [
    module.iam-role-ec2,
    module.lb
  ]
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
  platform_version                   = var.platform_version
  propagate_tags                     = var.propagate_tags
  scheduling_strategy                = var.scheduling_strategy
  task_definition                    = var.fargate_task_definition
  
  tags = module.labels.tags

  deployment_controller {
    type = var.type
  }

  capacity_provider_strategy {
    capacity_provider = var.fargate_capacity_provider_simple
    weight            = var.weight_simple
    base              = var.base
  }

  capacity_provider_strategy {
    capacity_provider = var.fargate_capacity_provider_spot
    weight            = var.weight_spot
  }

  load_balancer {
    target_group_arn = module.lb.main_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  depends_on = [
    module.lb
  ]
}