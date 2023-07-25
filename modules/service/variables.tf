
variable "additional_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Additional list of security groups that will be attached to the autoscaling group."
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of subnet IDs to launch resources in."
}

variable "instance_count" {
  type        = number
  default     = 0
  description = "The count of instances."
}

variable "ec2" {
  type        = list(any)
  sensitive   = true
  description = "The ID of the target. This is the Instance ID for an instance, or the container ID for an ECS container. If the target type is ip, specify an IP address."
}

variable "listener_certificate_arn" {
  type        = string
  sensitive   = true
  default     = ""
  description = "The ARN of the SSL server certificate. Exactly one certificate is required if the protocol is HTTPS."
}

#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}

## Service
variable "enabled" {
  type        = bool
  default     = false
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

variable "ec2_service_enabled" {
  type        = bool
  default     = false
  description = "Whether EC2 launch type is enabled."
}

variable "fargate_service_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate launch type is enabled or not."
}

variable "ec2_cluster_name" {
  type        = string
  default     = ""
  description = "The name of the ECS cluster."
}

variable "fargate_cluster_name" {
  type        = string
  default     = ""
  description = "The name of the ECS cluster."
}

variable "deployment_maximum_percent" {
  type        = number
  default     = 200
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment."
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  default     = 100
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
}

variable "desired_count" {
  type        = number
  default     = 0
  description = "The number of instances of the task definition to place and keep running."
}

variable "enable_ecs_managed_tags" {
  type        = bool
  default     = false
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service."
}

variable "health_check_grace_period_seconds" {
  type        = number
  default     = 60
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647."
}

variable "propagate_tags" {
  type        = string
  default     = "SERVICE"
  description = " Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION."
}

variable "scheduling_strategy" {
  type        = string
  default     = "REPLICA"
  description = "The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON."
}

variable "ec2_task_definition" {
  type        = string
  default     = ""
  description = "The family and revision (family:revision) or full ARN of the task definition that you want to run in your service."
}

variable "fargate_task_definition" {
  type        = string
  default     = ""
  description = "The family and revision (family:revision) or full ARN of the task definition that you want to run in your service."
}

variable "fargate_capacity_provider_simple" {
  type        = string
  default     = ""
  description = "The name of the capacity provider."
}

variable "fargate_capacity_provider_spot" {
  type        = string
  default     = ""
  description = "The name of the capacity provider."
}

variable "base" {
  type        = number
  default     = 1
  description = "The number of tasks, at a minimum, to run on the specified capacity provider."
}

variable "weight_simple" {
  type        = number
  default     = 1
  description = "The relative percentage of the total number of launched tasks that should use the specified capacity provider."
}

variable "weight_spot" {
  type        = number
  default     = 1
  description = "The relative percentage of the total number of launched tasks that should use the specified capacity provider."
}

variable "type" {
  type        = string
  default     = "ECS"
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS. Default: ECS."
}

variable "container_name" {
  type        = string
  default     = ""
  description = "The name of the container to associate with the load balancer (as it appears in a container definition)."
}

variable "container_port" {
  type        = number
  default     = 0
  description = "The port on the container to associate with the load balancer."
}

variable "subnets" {
  type        = list(string)
  default     = []
  description = "The subnets associated with the task or service."
}

variable "lb_subnet" {
  type        = list(string)
  default     = []
  description = "The subnet associated with the load balancer."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the EKS cluster."
}

variable "security_groups" {
  type        = list(string)
  default     = []
  description = "The security groups associated with the task or service."
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false."
}

variable "platform_version" {
  type        = string
  default     = "LATEST"
  description = "The platform version on which to run your service."
}

variable "ec2_awsvpc_enabled" {
  type        = bool
  default     = false
  description = "AWSVPC network mode is enabled or not."
}

variable "target_type" {
  type        = string
  default     = ""
  description = "The target type for load balancer."
}

variable "network_mode" {
  type        = string
  default     = ""
  description = "The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host."
}
