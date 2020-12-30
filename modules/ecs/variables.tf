#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
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
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}

## ECS Cluster

variable "enabled" {
  type        = bool
  default     = false
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

variable "ec2_cluster_enabled" {
  type        = bool
  default     = false
  description = "Whether ec2 cluster is enabled or not."
}

variable "fargate_cluster_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate cluster is enabled or not."
}

variable "fargate_cluster_cp" {
  type        = list(string)
  default     = []
  sensitive   = true
  description = "The name of the capacity provider."
}

variable "ecs_settings_enabled" {
  type        = string
  default     = ""
  sensitive   = true
  description = "Whether ecs setting is enabled or not."
}