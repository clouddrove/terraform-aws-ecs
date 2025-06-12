################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "ARN that identifies the cluster"
  value       = module.ecs_cluster.arn
}

output "cluster_id" {
  description = "ID that identifies the cluster"
  value       = module.ecs_cluster.id
}

output "cluster_name" {
  description = "Name that identifies the cluster"
  value       = module.ecs_cluster.name
}

################################################################################
# Service
################################################################################

output "service_id" {
  description = "ARN that identifies the service"
  value       = module.ecs_service.id
}

output "service_name" {
  description = "Name of the service"
  value       = module.ecs_service.name
}

output "service_iam_role_name" {
  description = "Service IAM role name"
  value       = module.ecs_service.iam_role_name
}

output "service_iam_role_arn" {
  description = "Service IAM role ARN"
  value       = module.ecs_service.iam_role_arn
}

output "service_container_definitions" {
  description = "Container definitions"
  value       = module.ecs_service.container_definitions
}

output "service_task_definition_arn" {
  description = "Full ARN of the Task Definition (including both `family` and `revision`)"
  value       = module.ecs_service.task_definition_arn
}

output "service_task_definition_revision" {
  description = "Revision of the task in a particular family"
  value       = module.ecs_service.task_definition_revision
}

output "service_task_exec_iam_role_name" {
  description = "Task execution IAM role name"
  value       = module.ecs_service.task_exec_iam_role_name
}

output "service_task_exec_iam_role_arn" {
  description = "Task execution IAM role ARN"
  value       = module.ecs_service.task_exec_iam_role_arn
}

output "service_tasks_iam_role_name" {
  description = "Tasks IAM role name"
  value       = module.ecs_service.tasks_iam_role_name
}

output "service_tasks_iam_role_arn" {
  description = "Tasks IAM role ARN"
  value       = module.ecs_service.tasks_iam_role_arn
}

output "service_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.ecs_service.security_group_arn
}

output "service_security_group_id" {
  description = "ID of the security group"
  value       = module.ecs_service.security_group_id
}

################################################################################
# Standalone Task Definition (w/o Service)
################################################################################

output "task_definition_run_task_command" {
  description = "awscli command to run the standalone task"
  value       = <<EOT
    aws ecs run-task --cluster ${module.ecs_cluster.name} \
      --task-definition ${module.ecs_task_definition.task_definition_family_revision} \
      --network-configuration "awsvpcConfiguration={subnets=[${join(",", module.subnets.private_subnet_id)}],securityGroups=[${module.ecs_task_definition.security_group_id}]}" \
      --region ${local.region}
  EOT
}
