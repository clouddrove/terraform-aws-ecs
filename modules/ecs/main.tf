locals {
  ec2_enabled     = var.enabled && var.autoscaling_policies_enabled ? true : false
  fargate_enabled = var.enabled && var.fargate_enabled ? true : false
}

#Module      : label
#Description : Terraform module to create consistent naming for multiple names.
module "labels" {
  source      = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.12.0"
  name        = var.name
  application = var.application
  environment = var.environment
  managedby   = var.managedby
  delimiter   = var.delimiter
  label_order = var.label_order
}

data "aws_iam_policy_document" "assume_role_ec2" {
  count = local.ec2_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#Module      : IAM ROLE
#Description : Provides an IAM role.
resource "aws_iam_role" "default" {
  count              = local.ec2_enabled ? 1 : 0
  name               = module.labels.id
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role_ec2.*.json)
}

#Module      : IAM ROLE POLICY ATTACHMENT NODE
#Description : Attaches a Managed IAM Policy to an IAM role.
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  count      = local.ec2_enabled ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = join("", aws_iam_role.default.*.name)
}

resource "aws_iam_instance_profile" "default" {
  count = local.ec2_enabled ? 1 : 0
  name  = format("%s-instance-profile", module.labels.id)
  role  = join("", aws_iam_role.default.*.name)
}

#Module      : SECURITY GROUP
#Description : Provides a security group resource.
resource "aws_security_group" "default" {
  count       = local.ec2_enabled ? 1 : 0
  name        = module.labels.id
  description = "Security Group for ECS instances"
  vpc_id      = var.vpc_id
  tags        = module.labels.tags
}

#Module      : SECURITY GROUP RULE EGRESS
#Description : Provides a security group rule resource. Represents a single egress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "egress" {
  count             = local.ec2_enabled ? 1 : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
  type              = "egress"
}

#Module      : SECURITY GROUP RULE INGRESS
#Description : Provides a security group rule resource. Represents a single egress group rule,
#              which can be added to external Security Groups.
resource "aws_security_group_rule" "ingress_alb" {
  count                    = local.ec2_enabled ? 1 : 0
  description              = "Allow instances to receive traffic from ALB"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = join("", aws_security_group.default.*.id)
  source_security_group_id = var.lb_security_group
  type                     = "ingress"
}

module "autoscale_group" {
  source = "../autoscaling"

  enabled     = local.ec2_enabled
  name        = var.name
  application = var.application
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  label_order = var.label_order

  image_id                  = var.image_id
  spot_image_id             = var.spot_image_id
  iam_instance_profile_name = join("", aws_iam_instance_profile.default.*.name)
  security_group_ids = compact(
    concat(
      [
        join("", aws_security_group.default.*.id)
      ],
      var.additional_security_group_ids
    )
  )
  user_data_base64 = base64encode(join("", data.template_file.ec2.*.rendered))
  tags             = module.labels.tags

  instance_type                           = var.instance_type
  subnet_ids                              = var.subnet_ids
  min_size                                = var.min_size
  max_size                                = var.max_size
  spot_max_size                           = var.spot_max_size
  spot_min_size                           = var.spot_min_size
  spot_enabled                            = var.spot_enabled
  scheduler_down                          = var.scheduler_down
  scheduler_up                            = var.scheduler_up
  min_size_scaledown                      = var.min_size_scaledown
  max_size_scaledown                      = var.max_size_scaledown
  spot_min_size_scaledown                 = var.spot_min_size_scaledown
  spot_max_size_scaledown                 = var.spot_max_size_scaledown
  schedule_enabled                        = var.schedule_enabled
  spot_schedule_enabled                   = var.spot_schedule_enabled
  spot_scale_down_desired                 = var.spot_scale_down_desired
  spot_scale_up_desired                   = var.spot_scale_up_desired
  scale_up_desired                        = var.scale_up_desired
  scale_down_desired                      = var.scale_down_desired
  max_price                               = var.max_price
  volume_size                             = var.volume_size
  ebs_encryption                          = var.ebs_encryption
  kms_key_arn                             = var.kms_key_arn
  volume_type                             = var.volume_type
  spot_instance_type                      = var.spot_instance_type
  associate_public_ip_address             = var.associate_public_ip_address
  instance_initiated_shutdown_behavior    = var.instance_initiated_shutdown_behavior
  key_name                                = var.key_name
  enable_monitoring                       = var.enable_monitoring
  load_balancers                          = var.load_balancers
  health_check_grace_period               = var.health_check_grace_period
  health_check_type                       = var.health_check_type
  min_elb_capacity                        = var.min_elb_capacity
  target_group_arns                       = var.target_group_arns
  default_cooldown                        = var.default_cooldown
  force_delete                            = var.force_delete
  termination_policies                    = var.termination_policies
  suspended_processes                     = var.suspended_processes
  enabled_metrics                         = var.enabled_metrics
  metrics_granularity                     = var.metrics_granularity
  wait_for_capacity_timeout               = var.wait_for_capacity_timeout
  protect_from_scale_in                   = var.protect_from_scale_in
  service_linked_role_arn                 = var.service_linked_role_arn
  autoscaling_policies_enabled            = var.autoscaling_policies_enabled
  scale_up_cooldown_seconds               = var.scale_up_cooldown_seconds
  scale_up_scaling_adjustment             = var.scale_up_scaling_adjustment
  scale_up_adjustment_type                = var.scale_up_adjustment_type
  scale_up_policy_type                    = var.scale_up_policy_type
  scale_down_cooldown_seconds             = var.scale_down_cooldown_seconds
  scale_down_scaling_adjustment           = var.scale_down_scaling_adjustment
  scale_down_adjustment_type              = var.scale_down_adjustment_type
  scale_down_policy_type                  = var.scale_down_policy_type
  cpu_utilization_high_evaluation_periods = var.cpu_utilization_high_evaluation_periods
  cpu_utilization_high_period_seconds     = var.cpu_utilization_high_period_seconds
  cpu_utilization_high_threshold_percent  = var.cpu_utilization_high_threshold_percent
  cpu_utilization_high_statistic          = var.cpu_utilization_high_statistic
  cpu_utilization_low_evaluation_periods  = var.cpu_utilization_low_evaluation_periods
  cpu_utilization_low_period_seconds      = var.cpu_utilization_low_period_seconds
  cpu_utilization_low_statistic           = var.cpu_utilization_low_statistic
  cpu_utilization_low_threshold_percent   = var.cpu_utilization_low_threshold_percent
}

data "template_file" "ec2" {
  count    = local.ec2_enabled ? 1 : 0
  template = file("${path.module}/user-data.tpl")

  vars = {
    cluster_name = var.cluster_name
  }
}

resource "aws_ecs_cluster" "ec2" {
  count = local.ec2_enabled ? 1 : 0
  name  = format("%s-cluster", module.labels.id)
  tags  = module.labels.tags

  setting {
    name = "containerInsights"
    value = var.ecs_settings_enabled
  }

  depends_on = [
    module.autoscale_group
  ]
}

resource "aws_ecs_cluster" "fargate" {
  count              = local.fargate_enabled ? 1 : 0
  name               = format("%s-cluster", module.labels.id)
  capacity_providers = var.capacity_providers
  tags               = module.labels.tags

  setting {
    name = "containerInsights"
    value = var.ecs_settings_enabled
  }

  default_capacity_providers {
    capacity_provider = var.capacity_providers
    weight            = var.weight
    base              = var.base
  }

  depends_on = [
    module.autoscale_group
  ]
}