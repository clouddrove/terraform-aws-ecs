output "launch_configuration_id" {
  description = "The ID of the launch configuration"
  value       = module.auto-scaling.launch_configuration_id
}

output "launch_configuration_arn" {
  description = "The ARN of the launch configuration"
  value       = module.auto-scaling.launch_configuration_arn
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.auto-scaling.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = module.auto-scaling.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.auto-scaling.autoscaling_group_arn
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = module.auto-scaling.autoscaling_group_min_size
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = module.auto-scaling.autoscaling_group_max_size
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = module.auto-scaling.autoscaling_group_desired_capacity
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = module.auto-scaling.autoscaling_group_default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value = join(
    "",
    module.auto-scaling.autoscaling_group_health_check_grace_period,
  )
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = module.auto-scaling.autoscaling_group_health_check_type
}

output "spot_autoscaling_group_id" {
  description = "The spot autoscaling group id"
  value       = module.auto-scaling.spot_autoscaling_group_id
}

output "spot_autoscaling_group_name" {
  description = "The spot autoscaling group name"
  value       = module.auto-scaling.spot_autoscaling_group_name
}

output "spot_autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.auto-scaling.spot_autoscaling_group_arn
}

output "auto_scaling_tags" {
  description = "The tags of the autoscaling group"
  value       = module.auto-scaling.tags
}

output "ecs_tags" {
  description = "The tags of the autoscaling group"
  value       = module.ecs.tags
}

output "ec2_cluster_id" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster"
  value       = module.ecs.ec2_id
}

output "ec2_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.ec2_name
}

output "ec2_cluster_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster"
  value       = module.ecs.ec2_arn
}

output "fargate_cluster_id" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster"
  value       = module.ecs.fargate_id
}

output "fargate_cluster_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster"
  value       = module.ecs.fargate_arn
}

output "ec2_service_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service"
  value       = module.service.ec2_id
}

output "ec2_service_name" {
  description = "The name of the service"
  value       = module.service.ec2_name
}

output "ec2_service_cluster" {
  description = " The Amazon Resource Name (ARN) of cluster which the service runs on"
  value       = module.service.ec2_cluster
}

output "ec2_service_iam_role" {
  description = "The ARN of IAM role used for LB"
  value       = module.service.ec2_iam_role
}

output "ec2_service_desired_count" {
  description = "The number of instances of the task definition"
  value       = module.service.ec2_desired_count  
}

output "fargate_service_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service"
  value       = module.service.fargate_id
}

output "fargate_service_name" {
  description = "The name of the service"
  value       = module.service.fargate_name  
}

output "fargate_service_cluster" {
  description = " The Amazon Resource Name (ARN) of cluster which the service runs on"
  value       = module.service.fargate_cluster
}

output "fargate_service_desired_count" {
  description = "The number of instances of the task definition"
  value       = module.service.fargate_desired_count  
}

output "service_tags" {
  description = "The tags of the service"
  value       = module.service.tags
}

output "ec2_td_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = module.task-definition.ec2_arn
}

output "ec2_td_family" {
  description = "The family of the Task Definition."
  value       = module.task-definition.ec2_family
}

output "ec2_td_revision" {
  description = "The revision of the task in a particular family."
  value       = module.task-definition.ec2_revision
}

output "fargate_td_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = module.task-definition.fargate_arn
}

output "fargate_td_family" {
  description = "The family of the Task Definition."
  value       = module.task-definition.fargate_family
}

output "fargate_td_revision" {
  description = "The revision of the task in a particular family."
  value       = module.task-definition.fargate_revision
}

output "td_tags" {
  description = "The tags of task definition"
  value       = module.task-definition.tags
}