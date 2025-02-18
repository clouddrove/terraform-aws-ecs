##-----------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##-----------------------------------------------------------------------------
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  repository  = var.repository
  environment = var.environment
  enabled     = var.enabled
  managedby   = var.managedby
  attributes  = compact(concat(var.attributes, ["autoscaling"]))
  label_order = var.label_order
}

##-----------------------------------------------------
## When your trusted identities assume IAM roles, they are granted only the permissions scoped by those IAM roles.
##-----------------------------------------------------
module "iam-role" {
  source  = "clouddrove/iam-role/aws"
  version = "1.3.2"

  name               = format("%s-instance-role", var.name)
  repository         = var.repository
  environment        = var.environment
  label_order        = var.label_order
  enabled            = var.enabled && var.fargate_cluster_enabled == false ? true : false
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json

  policy_enabled = true
  policy         = data.aws_iam_policy_document.iam_policy_ec2.json
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam_policy_ec2" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeTags",
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*",
      "ecs:PutAccountSetting",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

##-----------------------------------------------------
## instance profile is a container for an IAM role that you can use to pass role information to an Amazon EC2 instance when the instance starts
##-----------------------------------------------------
resource "aws_iam_instance_profile" "default" {
  count = var.enabled && var.fargate_cluster_enabled == false ? 1 : 0
  name  = format("%s-instance-profile", module.labels.id)
  role  = module.iam-role.name
}

##-----------------------------------------------------
## aws_security_group. Provides a security group resource.
##-----------------------------------------------------
resource "aws_security_group" "default" {
  count       = var.enabled ? 1 : 0
  name        = module.labels.id
  description = "Security Group for ECS instances"
  vpc_id      = var.vpc_id
  tags        = module.labels.tags
}

##-----------------------------------------------------
## Provides a security group rule resource. Represents a single egress group rule,
## which can be added to external Security Groups.
##-----------------------------------------------------
resource "aws_security_group_rule" "egress" {
  count             = var.enabled ? 1 : 0
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default[*].id)
  type              = "egress"
}

##-----------------------------------------------------
## Provides a security group rule resource. Represents a single egress group rule,
## which can be added to external Security Groups.
##-----------------------------------------------------
resource "aws_security_group_rule" "ingress_alb" {
  count                    = var.enabled ? 1 : 0
  description              = "Allow instances to receive traffic from ALB"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = join("", aws_security_group.default[*].id)
  source_security_group_id = var.lb_security_group
  type                     = "ingress"
}

data "template_file" "ec2" {
  count    = local.autoscaling_enabled ? 1 : 0
  template = file("${path.module}/user-data.tpl")

  vars = {
    cluster_name      = var.cluster_name
    cloudwatch_prefix = var.cloudwatch_prefix
  }
}

##-----------------------------------------------------
##  Provides a resource to create a new launch configuration, used for autoscaling groups.
##-----------------------------------------------------
resource "aws_launch_configuration" "default" {
  count = local.autoscaling_enabled ? 1 : 0

  name_prefix                 = format("%s%s", module.labels.id, var.delimiter)
  image_id                    = var.image_id
  instance_type               = var.instance_type
  iam_instance_profile        = join("", aws_iam_instance_profile.default[*].name)
  key_name                    = var.key_name
  security_groups             = compact(concat([join("", aws_security_group.default[*].id)], var.additional_security_group_ids))
  associate_public_ip_address = var.associate_public_ip_address
  user_data_base64            = base64encode(join("", data.template_file.ec2[*].rendered))
  enable_monitoring           = var.enable_monitoring
  ebs_optimized               = var.ebs_optimized

  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    encrypted             = var.ebs_encryption
    delete_on_termination = true
  }
}

##-----------------------------------------------------
##  Provides a resource to create a new launch configuration, used for autoscaling groups.
##-----------------------------------------------------
resource "aws_launch_configuration" "spot" {
  count = local.spot_autoscaling_enabled ? 1 : 0

  name_prefix                 = format("%sspot%s", module.labels.id, var.delimiter)
  image_id                    = var.image_id
  instance_type               = var.spot_instance_type
  iam_instance_profile        = join("", aws_iam_instance_profile.default[*].name)
  key_name                    = var.key_name
  security_groups             = compact(concat([join("", aws_security_group.default[*].id)], var.additional_security_group_ids))
  associate_public_ip_address = var.associate_public_ip_address
  user_data_base64            = base64encode(join("", data.template_file.ec2[*].rendered))
  enable_monitoring           = var.enable_monitoring
  ebs_optimized               = var.ebs_optimized
  spot_price                  = var.spot_price

  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    encrypted             = var.ebs_encryption
    delete_on_termination = true
  }
}

##-----------------------------------------------------
##  aws_autoscaling_group. Provides an Auto Scaling Group resource.
## Note: You must specify either launch_configuration , launch_template , or mixed_instances_policy.
##-----------------------------------------------------
resource "aws_autoscaling_group" "default" {
  count = local.autoscaling_enabled ? 1 : 0

  name_prefix               = format("%s%s", module.labels.id, var.delimiter)
  vpc_zone_identifier       = var.subnet_ids
  max_size                  = var.max_size
  min_size                  = var.min_size
  load_balancers            = var.load_balancers
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  min_elb_capacity          = var.min_elb_capacity
  target_group_arns         = var.target_group_arns
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = var.metrics_granularity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn
  launch_configuration      = join("", aws_launch_configuration.default[*].name)

  tag {
    key                 = "name"
    value               = module.labels.id
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_launch_configuration.default,
    module.iam-role,
    aws_iam_instance_profile.default
  ]
}

##-----------------------------------------------------
##  aws_autoscaling_group. Provides an Auto Scaling Group resource.
## Note: You must specify either launch_configuration , launch_template , or mixed_instances_policy.
##-----------------------------------------------------
resource "aws_autoscaling_group" "spot" {
  count = local.spot_autoscaling_enabled ? 1 : 0

  name_prefix               = format("%s%sspot%s", module.labels.id, var.delimiter, var.delimiter)
  vpc_zone_identifier       = var.subnet_ids
  max_size                  = var.spot_max_size
  min_size                  = var.spot_min_size
  load_balancers            = var.load_balancers
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  min_elb_capacity          = var.min_elb_capacity
  target_group_arns         = var.target_group_arns
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = var.metrics_granularity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn
  launch_configuration      = join("", aws_launch_configuration.spot[*].name)

  tag {
    key                 = "name"
    value               = module.labels.id
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_launch_configuration.spot,
    module.iam-role,
    aws_iam_instance_profile.default
  ]
}
