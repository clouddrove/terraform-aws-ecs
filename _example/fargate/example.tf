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

  name        = "sg_lb"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["0.0.0.0/0"]
  allowed_ports = [80]
}

module "lb" {
  source                     = "git::https://github.com/clouddrove/terraform-aws-alb.git?ref=tags/0.12.5"
  name                       = "alb"
  application                = "clouddrove"
  environment                = "test"
  label_order                = ["environment", "name", "application"]
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = module.sg_lb.security_group_ids
  subnets                    = module.subnets.public_subnet_id
  enable_deletion_protection = false
  target_type                = "ip"
  vpc_id                     = module.vpc.vpc_id
  target_group_protocol      = "HTTP"
  target_group_port          = 80
  http_enabled               = true
  https_enabled              = false
  https_port                 = 443
  target_id                  = []
  listener_type              = "forward"
}

module "ecs" {
  source = "../../"

  ## Tags
  name        = "ecs-fargate"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  enabled     = true

  ## Network
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.private_subnet_id

  ## Ec2
  target_group_arns                 = module.alb.main_target_group_arn
  lb_security_group                 = [module.sg_lb.security_group_ids]
  fargate_capacity_provider         = ["FARGATE"]
  default_fargate_capacity_provider = "FARGATE"

  ## Service
  desired_count       = 2
  propagate_tags      = "SERVICE"
  scheduling_strategy = "REPLICA"
  weight              = 1
  base                = 1
  container_name      = "nginx"
  container_port      = 80

  ## Task Definition
  fargate_enabled = true
  network_mode    = "awsvpc"
  ipc_mode        = "task"
  pid_mode        = "task"
  cpu             = 2
  memory          = 300
}