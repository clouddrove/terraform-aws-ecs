output "ecs_cluster_id" {
  description = "The id of the ecs cluster"
  value       = module.ecs.ec2_cluster_id
}

output "ecs_cluster_arn" {
  description = "The ARN of the ecs cluster"
  value       = module.ecs.ec2_cluster_arn
}

output "tags" {
  description = "The tags of the ecs cluster"
  value       = module.ecs.ecs_tags
}