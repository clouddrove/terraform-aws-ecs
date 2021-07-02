## ECS Cluster

output "ec2_id" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster"
  value       = join("", aws_ecs_cluster.ec2.*.id)
}

output "ec2_name" {
  description = "The name of the ECS cluster"
  value       = join("", aws_ecs_cluster.ec2.*.name)
}

output "ec2_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster"
  value       = join("", aws_ecs_cluster.ec2.*.arn)
}

output "fargate_id" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster"
  value       = join("", aws_ecs_cluster.fargate.*.id)
}

output "fargate_name" {
  description = "The name of the ECS cluster"
  value       = join("", aws_ecs_cluster.fargate.*.name)
}

output "fargate_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster"
  value       = join("", aws_ecs_cluster.fargate.*.arn)
}

output "tags" {
  description = "The tags of the ecs cluster"
  value       = module.labels.tags
}
