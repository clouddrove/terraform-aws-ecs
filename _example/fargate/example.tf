provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "git::https://github.com/clouddrove/terraform-aws-vpc.git?ref=tags/0.12.5"

  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  vpc_enabled = true

  cidr_block = "10.10.0.0/16"
}

module "subnets" {
  source = "git::https://github.com/clouddrove/terraform-aws-subnet.git?ref=tags/0.12.6"

  name        = "subnets"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  enabled     = true

  nat_gateway_enabled = true
  availability_zones  = ["eu-west-1a", "eu-west-1b"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  type                = "public-private"      
  igw_id              = module.vpc.igw_id
}

module "sg_lb" {
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.12.4"

  name        = "sg-lb"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["0.0.0.0/0"]
  allowed_ports = [80]
}

module "ecs" {
  source = "../../"

  ## Tags
  name        = "ecs-fargate"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  enabled     = false      # set to true after VPC, Subnets and Security Groups gets created

  ## Network
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.private_subnet_id

  ## Ec2
  lb_security_group         = module.sg_lb.security_group_ids
  service_lb_security_group = [module.sg_lb.security_group_ids]

  ## Fargate Cluster
  fargate_cluster_enabled = true  
  ecs_settings_enabled    = "enabled"
  fargate_cluster_cp      = ["FARGATE", "FARGATE_SPOT"]

  ## Service
  fargate_service_enabled          = true
  desired_count                    = 4
  assign_public_ip                 = true
  propagate_tags                   = "TASK_DEFINITION"
  lb_subnet                        = module.subnets.public_subnet_id
  scheduling_strategy              = "REPLICA"
  container_name                   = "nginx"
  container_port                   = 80
  target_type                      = "ip"
  weight_simple                    = 1
  weight_spot                      = 2
  base                             = 1
  fargate_capacity_provider_simple = "FARGATE"
  fargate_capacity_provider_spot   = "FARGATE_SPOT"

  ## Task Definition
  fargate_td_enabled = true
  cpu                = 512
  memory             = 1024
}