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

## Task Definition

variable "enabled" {
  type        = bool
  default     = false
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

variable "ec2_td_enabled" {
  type        = bool
  default     = false
  description = "Whether EC2 launch type is enabled."
}

variable "fargate_td_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate launch type is enabled or not."
}

variable "task_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
}

variable "network_mode" {
  type        = string
  default     = "bridge"
  description = "The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host."
}

variable "file_name" {
  type        = string
  default     = ""
  description = "File name for container definitions."
}

variable "container_log_group_name" {
  type        = string
  default     = "log-group"
  description = "Log group name for the container."
}

variable "ipc_mode" {
  type        = string
  default     = "task"
  description = "The IPC resource namespace to be used for the containers in the task The valid values are host, task, and none. (It does not support for fargate launch type)."
}

variable "pid_mode" {
  type        = string
  default     = "task"
  description = "The process namespace to use for the containers in the task. The valid values are host and task. (It does not support for fargate launch type)."
}

variable "cpu" {
  type        = number
  default     = 512
  description = "The number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
}

variable "memory" {
  type        = number
  default     = 1024
  description = "The amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "The retention of cloud watch logs."
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set."
}