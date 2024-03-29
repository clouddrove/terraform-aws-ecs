locals {
  autoscaling_enabled               = var.enabled && var.autoscaling_policies_enabled ? true : false
  spot_autoscaling_enabled          = var.enabled && var.autoscaling_policies_enabled && var.spot_enabled ? true : false
  autoscaling_enabled_schedule      = var.enabled && var.autoscaling_policies_enabled && var.schedule_enabled ? true : false
  autoscaling_enabled_spot_schedule = var.enabled && var.autoscaling_policies_enabled && var.spot_enabled && var.spot_schedule_enabled ? true : false
}

##-----------------------------------------------------------------------------
## aws_autoscaling_policy. Provides an AutoScaling Scaling Policy resource.
##-----------------------------------------------------------------------------
resource "aws_autoscaling_policy" "scale_up" {
  count                  = local.autoscaling_enabled ? 1 : 0
  name                   = format("%s%sscale%sup", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  policy_type            = var.scale_up_policy_type
  cooldown               = var.scale_up_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.default[*].name)
}

##-----------------------------------------------------------------------------
## aws_autoscaling_policy. Provides an AutoScaling Scaling Policy resource.
##-----------------------------------------------------------------------------
resource "aws_autoscaling_policy" "scale_up_spot" {
  count                  = local.spot_autoscaling_enabled ? 1 : 0
  name                   = format("%s%sscale%sup-spot", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_up_scaling_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  policy_type            = var.scale_up_policy_type
  cooldown               = var.scale_up_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.spot[*].name)
}

##-----------------------------------------------------------------------------
## Provides an AutoScaling Scaling Policy resource..
##-----------------------------------------------------------------------------
resource "aws_autoscaling_policy" "scale_down" {
  count                  = local.autoscaling_enabled ? 1 : 0
  name                   = format("%s%sscale%sdown", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  policy_type            = var.scale_down_policy_type
  cooldown               = var.scale_down_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.default[*].name)
}

##-----------------------------------------------------------------------------
## aws_autoscaling_policy. Provides an AutoScaling Scaling Policy resource.
##-----------------------------------------------------------------------------
resource "aws_autoscaling_policy" "scale_down_spot" {
  count                  = local.spot_autoscaling_enabled ? 1 : 0
  name                   = format("%s%sscale%sdown-spot", module.labels.id, var.delimiter, var.delimiter)
  scaling_adjustment     = var.scale_down_scaling_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  policy_type            = var.scale_down_policy_type
  cooldown               = var.scale_down_cooldown_seconds
  autoscaling_group_name = join("", aws_autoscaling_group.spot[*].name)
}

##-----------------------------------------------------------------------------
## creates Cloudwatch Alarm on AWS for monitoring AWS services.
##-----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count      = local.autoscaling_enabled ? 1 : 0
  alarm_name = format("%s%smemory%sreservation%shigh", module.labels.id, var.delimiter, var.delimiter, var.delimiter)

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.memory_reservation_high_evaluation_periods
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = var.memory_reservation_high_period_seconds
  statistic           = var.memory_reservation_high_statistic
  threshold           = var.memory_reservation_high_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = format("Scale up if memory reservation is above %s for %s seconds", var.memory_reservation_high_threshold_percent, var.memory_reservation_high_period_seconds)
  alarm_actions     = [join("", aws_autoscaling_policy.scale_up[*].arn)]
}

##-----------------------------------------------------------------------------
## creates Cloudwatch Alarm on AWS for monitoring AWS services.
##-----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_high_spot" {
  count      = local.spot_autoscaling_enabled ? 1 : 0
  alarm_name = format("%s%smemory%sreservation%shigh-spot", module.labels.id, var.delimiter, var.delimiter, var.delimiter)

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.memory_reservation_high_evaluation_periods
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = var.memory_reservation_high_period_seconds
  statistic           = var.memory_reservation_high_statistic
  threshold           = var.memory_reservation_high_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = format("Scale up if memory reservation is above %s for %s seconds", var.memory_reservation_high_threshold_percent, var.memory_reservation_high_period_seconds)
  alarm_actions     = [join("", aws_autoscaling_policy.scale_up_spot[*].arn)]
}

##-----------------------------------------------------------------------------
## creates Cloudwatch Alarm on AWS for monitoring AWS services.
##-----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_low" {
  count               = local.autoscaling_enabled ? 1 : 0
  alarm_name          = format("%s%smemory%sreservation%slow", module.labels.id, var.delimiter, var.delimiter, var.delimiter)
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.memory_reservation_low_evaluation_periods
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = var.memory_reservation_low_period_seconds
  statistic           = var.memory_reservation_low_statistic
  threshold           = var.memory_reservation_low_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = format("Scale down if memory reservation is above %s for %s seconds", var.memory_reservation_high_threshold_percent, var.memory_reservation_high_period_seconds)
  alarm_actions     = [join("", aws_autoscaling_policy.scale_down[*].arn)]
}

##-----------------------------------------------------------------------------
## creates Cloudwatch Alarm on AWS for monitoring AWS services.
##-----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_low_spot" {
  count               = local.spot_autoscaling_enabled ? 1 : 0
  alarm_name          = format("%s%smemory%sreservation%slow-spot", module.labels.id, var.delimiter, var.delimiter, var.delimiter)
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.memory_reservation_low_evaluation_periods
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = var.memory_reservation_low_period_seconds
  statistic           = var.memory_reservation_low_statistic
  threshold           = var.memory_reservation_low_threshold_percent
  tags                = module.labels.tags

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = format("Scale down if memory reservation is above %s for %s seconds", var.memory_reservation_high_threshold_percent, var.memory_reservation_high_period_seconds)
  alarm_actions     = [join("", aws_autoscaling_policy.scale_down_spot[*].arn)]
}

##-----------------------------------------------------------------------------
## aws_autoscaling_schedule. Provides an AutoScaling Schedule resource.
##-----------------------------------------------------------------------------
resource "aws_autoscaling_schedule" "scale_down" {
  count                  = local.autoscaling_enabled_schedule ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.default[0].name
  scheduled_action_name  = format("%s-scheduler-down", module.labels.id)
  min_size               = var.min_size_scaledown
  max_size               = var.max_size_scaledown
  desired_capacity       = var.scale_down_desired
  recurrence             = var.scheduler_down
}

##-----------------------------------------------------------------------------
## aws_autoscaling_schedule. Provides an AutoScaling Schedule resource.
##-----------------------------------------------------------------------------
resource "aws_autoscaling_schedule" "scale_up" {
  count                  = local.autoscaling_enabled_schedule ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.default[0].name
  scheduled_action_name  = format("%s-scheduler-up", module.labels.id)
  max_size               = var.max_size
  min_size               = var.min_size
  desired_capacity       = var.scale_up_desired
  recurrence             = var.scheduler_up
}

##-----------------------------------------------------------------------------
## aws_autoscaling_schedule. Provides an AutoScaling Schedule resource.
##-----------------------------------------------------------------------------
resource "aws_autoscaling_schedule" "spot_scaledown" {
  count                  = local.autoscaling_enabled_spot_schedule ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.spot[0].name
  scheduled_action_name  = format("spot-%s-scheduler-down", module.labels.id)
  min_size               = var.spot_min_size_scaledown
  max_size               = var.spot_max_size_scaledown
  desired_capacity       = var.spot_scale_down_desired
  recurrence             = var.scheduler_down
}

##-----------------------------------------------------------------------------
## aws_autoscaling_schedule. Provides an AutoScaling Schedule resource.
##-----------------------------------------------------------------------------
resource "aws_autoscaling_schedule" "spot_scaleup" {
  count                  = local.autoscaling_enabled_spot_schedule ? 1 : 0
  autoscaling_group_name = aws_autoscaling_group.spot[0].name
  scheduled_action_name  = format("spot-%s-scheduler-up", module.labels.id)
  max_size               = var.spot_max_size
  min_size               = var.spot_min_size
  desired_capacity       = var.spot_scale_up_desired
  recurrence             = var.scheduler_up
}
