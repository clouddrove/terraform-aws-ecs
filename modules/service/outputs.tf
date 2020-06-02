## Service

output "ec2_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service"
  value       = join("", aws_ecs_service.ec2.*.id)
}

output "ec2_name" {
  description = "The name of the service"
  value       = join("", aws_ecs_service.ec2.*.name)
}

output "ec2_cluster" {
  description = " The Amazon Resource Name (ARN) of cluster which the service runs on"
  value       = join("", aws_ecs_service.ec2.*.cluster)
}

output "ec2_iam_role" {
  description = "The ARN of IAM role used for LB"
  value       = join("", aws_ecs_service.ec2.*.iam_role)
}

output "ec2_desired_count" {
  description = "The number of instances of the task definition"
  value       = join("", aws_ecs_service.ec2.*.desired_count)
}

output "fargate_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service"
  value       = join("", aws_ecs_service.fargate.*.id)
}

output "fargate_name" {
  description = "The name of the service"
  value       = join("", aws_ecs_service.fargate.*.name)
}

output "fargate_cluster" {
  description = " The Amazon Resource Name (ARN) of cluster which the service runs on"
  value       = join("", aws_ecs_service.fargate.*.cluster)
}

output "fargate_desired_count" {
  description = "The number of instances of the task definition"
  value       = join("", aws_ecs_service.fargate.*.desired_count)
}

output "tags" {
  description = "The tags of the service"
  value       = module.labels.tags
}