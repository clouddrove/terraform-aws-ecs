#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "application" {
  type        = string
  default     = ""
  description = "Application (e.g. `cd` or `clouddrove`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map
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

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

variable "ec2_enabled" {
  type        = bool
  default     = false
  description = "Whether EC2 launch type is enabled."
}

variable "fargate_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate launch type is enabled or not."
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "The name of the ECS cluster."
}

variable "deployment_maximum_percent" {
  type        = number
  default     = 200
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment."
}

variable "deployment_minimum_health_percent" {
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
  default     = true
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service."
}

variable "health_check_grace_period_seconds" {
  type        = number
  default     = 5000
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647."
}

variable "launch_type" {
  type        = string
  default     = "EC2"
  description = "The launch type on which to run your service. The valid values are EC2 and FARGATE. Defaults to EC2."
}

variable "propagate_tags" {
  type        = string
  default     = "TASK_DEFINITION"
  description = " Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION."
}

variable "scheduling_strategy" {
  type        = string
  default     = "REPLICA"
  description = "The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON."
}

variable "task_definition" {
  type        = string
  default     = ""
  description = "The family and revision (family:revision) or full ARN of the task definition that you want to run in your service."
}

variable "capacity_provider" {
  type        = string
  default     = ""
  description = "The name of the capacity provider."
}

variable "base" {
  type        = number
  default     = 1
  description = "The number of tasks, at a minimum, to run on the specified capacity provider."
}

variable "weight" {
  type        = number
  default     = 1
  description = "The relative percentage of the total number of launched tasks that should use the specified capacity provider."
}

variable "type" {
  type        = string
  default     = "ECS"
  description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS. Default: ECS."
}

variable "target_group_arn" {
  type        = string
  default     = ""
  description = "(Required for ALB/NLB) The ARN of the Load Balancer target group to associate with the service."
}

variable "container_name" {
  type        = string
  default     = ""
  description = "The name of the container to associate with the load balancer (as it appears in a container definition)."
}

variable "container_port" {
  type        = number
  default     = 80
  description = "The port on the container to associate with the load balancer."
}

variable "subnets" {
  type        = list
  default     = []
  description = "The subnets associated with the task or service."
}

variable "security_groups" {
  type        = string
  default     = ""
  description = "The security groups associated with the task or service."
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false."
}