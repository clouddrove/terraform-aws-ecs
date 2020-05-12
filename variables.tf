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
  default     = false
  description = "Whether to create the resources. Set to `false` to prevent the module from creating any resources."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the EKS cluster."
}

variable "image_id" {
  type        = string
  default     = ""
  description = "The EC2 image ID to launch."
}

variable "instance_type" {
  type        = string
  default     = ""
  description = "Instance type to launch."
}

variable "key_name" {
  type        = string
  default     = ""
  description = "The SSH key name that should be used for the instance."
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
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
  description = "A list of subnet IDs to launch resources in."
}

variable "health_check_type" {
  type        = string
  default     = "EC2"
  description = "Controls how health checking is done. Valid values are `EC2` or `ELB`."
}

variable "load_balancers" {
  type        = list(string)
  default     = []
  description = "A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead."
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing."
}

variable "target_group_arn" {
  type        = string
  default     = ""
  description = "A string of aws_alb_target_group ARNs, for use with Application Load Balancing."
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

variable "cpu_utilization_high_threshold_percent" {
  type        = number
  default     = 90
  description = "The value against which the specified statistic is compared."
}

variable "cpu_utilization_low_threshold_percent" {
  type        = number
  default     = 10
  description = "The value against which the specified statistic is compared."
}

variable "volume_size" {
  type        = number
  default     = 100
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

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set."
}

## Spot

variable "spot_enabled" {
  type        = bool
  default     = false
  description = "Whether to create the spot instance. Set to `false` to prevent the module from creating any  spot instances."
}

variable "spot_image_id" {
  type        = string
  default     = ""
  description = "The Spot EC2 image ID to launch."
}

variable "max_price" {
  type        = string
  default     = ""
  description = "The maximum hourly price you're willing to pay for the Spot Instances."
}

variable "spot_instance_type" {
  type        = string
  default     = ""
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

variable "fargate_enabled" {
  type        = bool
  default     = false
  description = "Whether fargate is enabled or not."
}

variable "additional_security_group_ids" {
  type        = list(string)
  default     = []
  description = "Additional list of security groups that will be attached to the autoscaling group."
}

variable "ecs_settings_enabled" {
  type        = string
  default     = ""
  description = "Whether ecs setting is enabled or not."
}

variable "fargate_capacity_provider" {
  type        = list(string)
  default     = []
  description = "The name of the capacity provider."
}

variable "default_fargate_capacity_provider" {
  type        = string
  default     = ""
  description = "The name of the default capacity provider."
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

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "The retention of cloud watch logs."
}

variable "ecs_logging" {
  default     = "[\"json-file\",\"awslogs\"]"
  description = "Adding logging option to ECS that the Docker containers can use. It is possible to add fluentd as well"
}

variable "cloudwatch_prefix" {
  type        = string
  default     = ""
  description = "The prefix of cloudwatch logs."
}

variable "lb_security_group" {
  type        = string
  default     = ""
  description = "The LB security groups."
}

## Service and Task Definition Variables

variable "ec2_enabled" {
  type        = bool
  default     = false
  description = "Whether EC2 launch type is enabled."
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
  default     = 360
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647."
}

variable "propagate_tags" {
  type        = string
  default     = ""
  description = " Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK_DEFINITION."
}

variable "scheduling_strategy" {
  type        = string
  default     = ""
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

variable "platform_version" {
  type        = string
  default     = "LATEST"
  description = "The platform version on which to run your service."
}

variable "task_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
}

variable "execution_role_arn" {
  type        = string
  default     = ""
  description = "The Amazon Resource Name (ARN) of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
}

variable "network_mode" {
  type        = string
  default     = ""
  description = "The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host."
}

variable "ipc_mode" {
  type        = string
  default     = ""
  description = "The IPC resource namespace to be used for the containers in the task The valid values are host, task, and none."
}

variable "pid_mode" {
  type        = string
  default     = ""
  description = "The process namespace to use for the containers in the task. The valid values are host and task."
}

variable "cpu" {
  type        = number
  default     = 2
  description = "The number of cpu units used by the task. If the requires_compatibilities is FARGATE this field is required."
}

variable "memory" {
  type        = number
  default     = 500
  description = "The amount (in MiB) of memory used by the task. If the requires_compatibilities is FARGATE this field is required."
}

variable "service_lb_security_group" {
  type        = list(string)
  default     = []
  description = "The service LB security groups."
}