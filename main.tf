##-----------------------------------------------------------------------------
## auto-scaling module call.
##-----------------------------------------------------------------------------
module "auto-scaling" {
  source                                    = "./modules/auto-scaling"
  name                                      = var.name
  repository                                = var.repository
  environment                               = var.environment
  managedby                                 = var.managedby
  delimiter                                 = var.delimiter
  label_order                               = var.label_order
  attributes                                = var.attributes
  tags                                      = var.tags
  image_id                                  = var.image_id
  instance_type                             = var.instance_type
  vpc_id                                    = var.vpc_id
  subnet_ids                                = var.subnet_ids
  health_check_type                         = var.health_check_type
  min_size                                  = var.min_size
  max_size                                  = var.max_size
  spot_max_size                             = var.spot_max_size
  spot_min_size                             = var.spot_min_size
  spot_enabled                              = var.spot_enabled
  spot_scale_down_desired                   = var.spot_scale_down_desired
  spot_scale_up_desired                     = var.spot_scale_up_desired
  scale_up_desired                          = var.scale_up_desired
  scale_down_desired                        = var.scale_down_desired
  schedule_enabled                          = var.schedule_enabled
  spot_schedule_enabled                     = var.spot_schedule_enabled
  scheduler_down                            = var.scheduler_down
  scheduler_up                              = var.scheduler_up
  min_size_scaledown                        = var.min_size_scaledown
  max_size_scaledown                        = var.max_size_scaledown
  spot_min_size_scaledown                   = var.spot_min_size_scaledown
  spot_max_size_scaledown                   = var.spot_max_size_scaledown
  spot_price                                = var.spot_price
  volume_size                               = var.volume_size
  ebs_encryption                            = var.ebs_encryption
  ebs_optimized                             = var.ebs_optimized
  volume_type                               = var.volume_type
  spot_instance_type                        = var.spot_instance_type
  load_balancers                            = var.load_balancers
  target_group_arns                         = var.target_group_arns
  wait_for_capacity_timeout                 = var.wait_for_capacity_timeout
  associate_public_ip_address               = var.associate_public_ip_address
  enabled                                   = var.enabled
  key_name                                  = var.key_name
  autoscaling_policies_enabled              = var.autoscaling_policies_enabled
  memory_reservation_high_threshold_percent = var.memory_reservation_high_threshold_percent
  memory_reservation_low_threshold_percent  = var.memory_reservation_low_threshold_percent
  additional_security_group_ids             = var.additional_security_group_ids
  lb_security_group                         = var.lb_security_group
  cloudwatch_prefix                         = var.cloudwatch_prefix
  retention_in_days                         = var.retention_in_days
  kms_key_arn                               = var.kms_key_arn
  fargate_cluster_enabled                   = var.fargate_cluster_enabled
  cluster_name                              = module.ecs.ec2_name
}

##-----------------------------------------------------------------------------
## ecs module call.
##-----------------------------------------------------------------------------
module "ecs" {
  source                  = "./modules/ecs"
  name                    = var.name
  repository              = var.repository
  environment             = var.environment
  managedby               = var.managedby
  delimiter               = var.delimiter
  attributes              = var.attributes
  label_order             = var.label_order
  tags                    = var.tags
  enabled                 = var.enabled
  ec2_cluster_enabled     = var.ec2_cluster_enabled
  fargate_cluster_enabled = var.fargate_cluster_enabled
  ecs_settings_enabled    = var.ecs_settings_enabled
  fargate_cluster_cp      = var.fargate_cluster_cp
}

##-----------------------------------------------------------------------------
## service module call.
##-----------------------------------------------------------------------------
module "service" {
  source                             = "./modules/service"
  name                               = var.name
  environment                        = var.environment
  managedby                          = var.managedby
  delimiter                          = var.delimiter
  attributes                         = var.attributes
  label_order                        = var.label_order
  tags                               = var.tags
  enabled                            = var.enabled
  ec2_service_enabled                = var.ec2_service_enabled
  ec2_cluster_name                   = module.ecs.ec2_id
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  desired_count                      = var.desired_count
  enable_ecs_managed_tags            = var.enable_ecs_managed_tags
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds
  ec2_awsvpc_enabled                 = var.ec2_awsvpc_enabled
  propagate_tags                     = var.propagate_tags
  scheduling_strategy                = var.scheduling_strategy
  ec2_task_definition                = module.task-definition.ec2_arn
  type                               = var.type
  container_name                     = var.container_name
  container_port                     = var.container_port
  fargate_service_enabled            = var.fargate_service_enabled
  fargate_cluster_name               = module.ecs.fargate_id
  platform_version                   = var.platform_version
  fargate_task_definition            = module.task-definition.fargate_arn
  fargate_capacity_provider_simple   = var.fargate_capacity_provider_simple
  fargate_capacity_provider_spot     = var.fargate_capacity_provider_spot
  weight_simple                      = var.weight_simple
  weight_spot                        = var.weight_spot
  base                               = var.base
  subnets                            = var.subnet_ids
  security_groups                    = var.service_lb_security_group
  assign_public_ip                   = var.assign_public_ip
  lb_subnet                          = var.lb_subnet
  vpc_id                             = var.vpc_id
  target_type                        = var.target_type
  network_mode                       = var.network_mode
}

##-----------------------------------------------------------------------------
## task-definition module call.
##-----------------------------------------------------------------------------
module "task-definition" {
  source                   = "./modules/task-definition"
  name                     = var.name
  environment              = var.environment
  managedby                = var.managedby
  delimiter                = var.delimiter
  attributes               = var.attributes
  label_order              = var.label_order
  tags                     = var.tags
  enabled                  = var.enabled
  ec2_td_enabled           = var.ec2_td_enabled
  fargate_td_enabled       = var.fargate_td_enabled
  task_role_arn            = var.task_role_arn
  file_name                = var.file_name
  container_log_group_name = var.container_log_group_name
  ipc_mode                 = var.ipc_mode
  pid_mode                 = var.pid_mode
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = var.network_mode
  kms_key_arn              = var.kms_key_arn
  retention_in_days        = var.retention_in_days
}