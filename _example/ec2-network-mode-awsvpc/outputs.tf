output "ecs_cluster_name" {
  description = "The name of the ecs cluster"
  value       = module.ecs.ec2_cluster_name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ecs cluster"
  value       = module.ecs.ec2_cluster_arn
}

output "tags" {
  description = "The tags of the ecs cluster"
  value       = module.ecs.ecs_tags
}