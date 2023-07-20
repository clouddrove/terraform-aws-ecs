## EC2

output "launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = join("", aws_launch_configuration.default.*.id)
}

output "launch_configuration_arn" {
  description = "The ARN of the launch configuration"
  value       = join("", aws_launch_configuration.default.*.arn)
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = join("", aws_autoscaling_group.default.*.id)
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = join("", aws_autoscaling_group.default.*.name)
}

output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = join("", aws_autoscaling_group.default.*.arn)
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = join("", aws_autoscaling_group.default.*.min_size)
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = join("", aws_autoscaling_group.default.*.max_size)
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = join("", aws_autoscaling_group.default.*.desired_capacity)
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = join("", aws_autoscaling_group.default.*.default_cooldown)
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = aws_autoscaling_group.default.*.health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = join("", aws_autoscaling_group.default.*.health_check_type)
}

output "spot_autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = join("", aws_autoscaling_group.spot.*.id)
}

output "spot_autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = join("", aws_autoscaling_group.spot.*.name)
}

output "spot_autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = join("", aws_autoscaling_group.spot.*.arn)
}

output "tags" {
  description = "The tags of the autoscaling group"
  value       = module.labels.tags
}