output "ecs_cluster_name" {
  description = "The name of the ecs cluster"
  value       = module.ecs_cluster.fargate_name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ecs cluster"
  value       = module.ecs_cluster.fargate_arn
}

output "tags" {
  description = "The tags of the ecs cluster"
  value       = module.ecs_cluster.tags
}

output "lb_arn" {
  value = module.lb.arn
}

output "lb_target_group_arn" {
  value = module.lb.main_target_group_arn
}