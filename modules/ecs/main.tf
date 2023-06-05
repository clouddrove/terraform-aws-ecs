locals {
  ec2_enabled     = var.enabled && var.ec2_cluster_enabled ? true : false
  fargate_enabled = var.enabled && var.fargate_cluster_enabled ? true : false
}

##-----------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##-----------------------------------------------------------------------------
module "labels" {
  source      = "clouddrove/labels/aws"
  version     = "1.3.0"
  name        = var.name
  repository  = var.repository
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  attributes  = compact(concat(var.attributes, ["cluster"]))
  label_order = var.label_order
}

##-----------------------------------------------------------------------------
## An Amazon ECS cluster groups together tasks, and services, and allows for shared capacity and common configurations.
##-----------------------------------------------------------------------------
resource "aws_ecs_cluster" "ec2" {
  count = local.ec2_enabled ? 1 : 0
  name  = module.labels.id
  tags  = module.labels.tags

  setting {
    name  = "containerInsights"
    value = var.ecs_settings_enabled
  }
}

##-----------------------------------------------------------------------------
## An Amazon ECS cluster groups together tasks, and services, and allows for shared capacity and common configurations.
##-----------------------------------------------------------------------------
resource "aws_ecs_cluster" "fargate" {
  count = local.fargate_enabled ? 1 : 0
  name  = module.labels.id
  tags  = module.labels.tags

}

resource "aws_ecs_cluster_capacity_providers" "example" {
  count        = local.fargate_enabled ? 1 : 0
  cluster_name = join("", aws_ecs_cluster.fargate.*.name)

  capacity_providers = var.fargate_cluster_cp

}