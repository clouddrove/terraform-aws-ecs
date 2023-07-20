## Task Definition
output "ec2_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = join("", aws_ecs_task_definition.ec2.*.arn)
}

output "ec2_family" {
  description = "The family of the Task Definition."
  value       = join("", aws_ecs_task_definition.ec2.*.family)
}

output "ec2_revision" {
  description = "The revision of the task in a particular family."
  value       = join("", aws_ecs_task_definition.ec2.*.revision)
}

output "fargate_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)."
  value       = join("", aws_ecs_task_definition.fargate.*.arn)
}

output "fargate_family" {
  description = "The family of the Task Definition."
  value       = join("", aws_ecs_task_definition.fargate.*.family)
}

output "fargate_revision" {
  description = "The revision of the task in a particular family."
  value       = join("", aws_ecs_task_definition.fargate.*.revision)
}

output "tags" {
  description = "The tags of task definition"
  value       = module.labels.tags
}