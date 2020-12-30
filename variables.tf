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

## EC2

variable "enabled" {
  type        = bool
  default     = false
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

variable "image_id" {
  type        = string
  default     = ""
  sensitive   = true
  description = "The EC2 image ID to launch."
}

variable "instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Instance type to launch."
}

variable "key_name" {
  type        = string
  default     = ""
  sensitive   = true
  description = "The SSH key name that should be used for the instance."
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  sensitive   = true
  description = "A list of associated security group IDs."
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Associate a public IP address with an instance in a VPC."
}

variable "max_size" {
  type        = number
  default     = 3
  description = "The maximum size of the autoscale group."
}

variable "min_size" {
  type        = number
  default     = 0
  description = "The minimum size of the autoscale group."
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  sensitive   = true
  description = "A list of subnet IDs to launch resources in."
}

variable "health_check_type" {
  type        = string
  default     = "EC2"
  sensitive   = true
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`."
}

variable "load_balancers" {
  type        = list(string)
  default     = []
  sensitive   = true
  description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead."
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  sensitive   = true
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing."
}

variable "ebs_optimized" {
  type        = bool
  default     = true
  description = "If true, the launched EC2 instance will be EBS-optimized."
}

variable "wait_for_capacity_timeout" {
  type        = string
  default     = "15m"
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
}

variable "autoscaling_policies_enabled" {
  type        = bool
  default     = false
  description = "Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling."
}

variable "memory_reservation_high_threshold_percent" {
  type        = number
  default     = 75
  description = "The value against which the specified statistic is compared."
}

variable "memory_reservation_low_threshold_percent" {
  type        = number
  default     = 25
  description = "The value against which the specified statistic is compared."
}

variable "volume_size" {
  type        = number
  default     = 50
  description = "The size of ebs volume."
}

variable "volume_type" {
  type        = string
  default     = "gp2"
  description = "The type of volume. Can be `standard`, `gp2`, or `io1`. (Default: `standard`)."
}

variable "ebs_encryption" {
  type        = bool
  default     = false
  description = "Enables EBS encryption on the volume (Default: false). Cannot be used with snapshot_id."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the EKS cluster."
  sensitive   = true
}

variable "additional_security_group_ids" {
  type        = list(string)
  sensitive   = true
  default     = []
  description = "Additional list of security groups that will be attached to the autoscaling group."
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "The retention of cloud watch logs."
}

variable "cloudwatch_prefix" {
  type        = string
  default     = ""
  description = "The prefix of cloudwatch logs."
}

variable "lb_security_group" {
  type        = string
  default     = ""
  sensitive   = true
  description = "The LB security groups."
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  sensitive   = true
  description = "AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set."
}

## Spot

variable "spot_enabled" {
  type        = bool
  default     = false
  description = "Whether to create the spot instance. Set to `false` to prevent the module from creating any  spot instances."
}

variable "spot_price" {
  type        = number
  default     = 1
  description = "The maximum hourly price you're willing to pay for the Spot Instances."
}

variable "spot_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Sport instance type to launch."
}

variable "spot_max_size" {
  type        = number
  default     = 3
  description = "The maximum size of the spot autoscale group."
}

variable "spot_min_size" {
  type        = number
  default     = 0
  description = "The minimum size of the spot autoscale group."
}

variable "scheduler_down" {
  type        = string
  default     = "0 19 * * MON-FRI"
  description = "What is the recurrency for scaling up operations ?"
}

variable "scheduler_up" {
  type        = string
  default     = "0 6 * * MON-FRI"
  description = "What is the recurrency for scaling down operations ?"
}

variable "min_size_scaledown" {
  type        = number
  default     = 0
  description = "The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "max_size_scaledown" {
  type        = number
  default     = 1
  description = "The maximum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "spot_min_size_scaledown" {
  type        = number
  default     = 0
  description = "The minimum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "spot_max_size_scaledown" {
  type        = number
  default     = 1
  description = "The maximum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time."
}

variable "scale_down_desired" {
  type        = number
  default     = 0
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "spot_scale_down_desired" {
  type        = number
  default     = 0
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "scale_up_desired" {
  type        = number
  default     = 0
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "spot_scale_up_desired" {
  type        = number
  default     = 0
  description = " The number of Amazon EC2 instances that should be running in the group."
}

variable "schedule_enabled" {
  type        = bool
  default     = false
  description = "AutoScaling Schedule resource"
}

variable "spot_schedule_enabled" {
  type        = bool
  default     = false
  description = "AutoScaling Schedule resource for spot"
}

## ECS Cluster

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

variable "ecs_settings_enabled" {
  type        = string
  default     = ""
  description = "Whether ecs setting is enabled or not."
}

variable "fargate_cluster_cp" {
  type        = list(string)
  default     = []
  description = "The name of the capacity provider."
}

## Service

variable "ec2_service_enabled" {
  type        = bool
  default     = false
  description = "Whether EC2 launch type is enabled."
}

variable "fargate_service_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate is enabled or not."
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
  default     = 360
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
  default     = 80
  description = "The port on the container to associate with the load balancer."
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false."
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

variable "platform_version" {
  type        = string
  default     = "LATEST"
  description = "The platform version on which to run your service."
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

variable "service_lb_security_group" {
  type        = list(string)
  default     = []
  sensitive   = true
  description = "The service LB security groups."
}

variable "lb_subnet" {
  type        = list(string)
  default     = []
  sensitive   = true
  description = "The subnet associated with the load balancer."
}

variable "target_type" {
  type        = string
  default     = ""
  description = "The target type for load balancer."
}

variable "ec2_awsvpc_enabled" {
  type        = bool
  default     = false
  description = "AWSVPC network mode is enabled or not."
}

## Task Definition

variable "task_role_arn" {
  type        = string
  default     = ""
  sensitive   = true
  description = "The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
}

variable "network_mode" {
  type        = string
  default     = "bridge"
  description = "The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host."
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

variable "ec2_td_enabled" {
  type        = bool
  default     = false
  description = "Whether EC2 task definition is enabled."
}

variable "fargate_td_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate task definition is enabled."
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