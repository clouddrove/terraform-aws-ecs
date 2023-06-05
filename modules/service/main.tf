locals {
  ec2_enabled     = var.enabled && var.ec2_service_enabled ? true : false
  fargate_enabled = var.enabled && var.fargate_service_enabled ? true : false
}

##-----------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##-----------------------------------------------------------------------------
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  attributes  = compact(concat(var.attributes, ["service"]))
  label_order = var.label_order
}

##-----------------------------------------------------
## When your trusted identities assume IAM roles, they are granted only the permissions scoped by those IAM roles.
##-----------------------------------------------------
module "iam-role-ecs" {
  source  = "clouddrove/iam-role/aws"
  version = "1.3.0"

  name               = format("%s-lb", var.name)
  environment        = var.environment
  label_order        = var.label_order
  enabled            = var.enabled && var.network_mode == "bridge" ? true : false
  assume_role_policy = data.aws_iam_policy_document.assume_role_ecs.json

  policy_enabled = true
  policy_arn     = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "assume_role_ecs" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

##-----------------------------------------------------
## Application Load Balancer (ALB) is a fully managed layer 7 load balancing service that load balances incoming traffic across multiple targets, such as Amazon EC2 instances.
##-----------------------------------------------------
module "lb" {
  source  = "clouddrove/alb/aws"
  version = "1.3.0"

  name                       = format("%s-alb", var.name)
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
  target_group_port          = 80
  http_enabled               = false
  https_enabled              = true
  https_port                 = 80
  target_id                  = []
  listener_type              = "forward"
  listener_protocol          = "HTTP"
}

##-----------------------------------------------------
## aws_ecs_service. An Amazon ECS service allows you to run and maintain a specified number of instances of a task definition simultaneously in an Amazon ECS cluster.
##-----------------------------------------------------
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
  iam_role                           = var.network_mode == "bridge" ? module.iam-role-ecs.arn : ""
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
    module.iam-role-ecs,
    module.lb
  ]
}

##-----------------------------------------------------
## aws_ecs_service. An Amazon ECS service allows you to run and maintain a specified number of instances of a task definition simultaneously in an Amazon ECS cluster.
##-----------------------------------------------------
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
  }

  capacity_provider_strategy {
    capacity_provider = var.fargate_capacity_provider_spot
    weight            = var.weight_spot
    base              = var.base
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