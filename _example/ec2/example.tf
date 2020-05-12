provider "aws" {
  region = "eu-west-1"
}

module "keypair" {
  source = "git::https://github.com/clouddrove/terraform-aws-keypair.git?ref=tags/0.12.2"

  key_path        = "~/.ssh/id_rsa.pub"
  key_name        = "main-key"
  enable_key_pair = true
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

module "sg_ssh" {
  source = "git::https://github.com/clouddrove/terraform-aws-security-group.git?ref=tags/0.12.4"

  name        = "sg_ssh"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["49.36.133.174/32", module.vpc.vpc_cidr_block]
  allowed_ports = [22]
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
  security_groups            = [module.sg_lb.security_group_ids]
  subnets                    = module.subnets.public_subnet_id
  enable_deletion_protection = false
  target_type                = "instance"
  vpc_id                     = module.vpc.vpc_id
  target_group_protocol      = "HTTP"
  target_group_port          = 80
  http_enabled               = true
  https_enabled              = false
  https_port                 = 443
  target_id                  = []
  listener_type              = "forward"
}

module "kms_key" {
    source      = "git::https://github.com/clouddrove/terraform-aws-kms.git?ref=tags/0.12.5"
    
    name        = "kms"
    application = "clouddrove"
    environment = "test"
    label_order = ["environment", "application", "name"]
    enabled     = true
    
    description              = "KMS key for eks"
    alias                    = "alias/ecs"
    key_usage                = "ENCRYPT_DECRYPT"
    customer_master_key_spec = "SYMMETRIC_DEFAULT"
    deletion_window_in_days  = 7
    is_enabled               = true
    enable_key_rotation      = false
    policy                   = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  version = "2012-10-17"
  
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "ecs" {
  source = "../../"

  ## Tags
  name        = "ecs"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  enabled     = true

  ## Network
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.subnets.private_subnet_id
  additional_security_group_ids   = [module.sg_ssh.security_group_ids]

  ## Ec2
  autoscaling_policies_enabled = true  
  key_name                     = module.keypair.name
  image_id                     = "ami-0a74b180a0c97ecd1"
  instance_type                = "t2.medium"
  min_size                     = 0
  max_size                     = 3
  volume_size                  = 25
  target_group_arns            = [module.lb.main_target_group_arn]
  lb_security_group            = module.sg_lb.security_group_ids
  service_lb_security_group    = [module.sg_lb.security_group_ids]
  target_group_arn             = module.lb.main_target_group_arn
  cloudwatch_prefix            = "ecs-logs"
  ecs_settings_enabled         = "enabled"

  ## Schedule
  scheduler_down = "0 19 * * MON-FRI"
  scheduler_up   = "0 6 * * MON-FRI"

  schedule_enabled   = true
  min_size_scaledown = 0
  max_size_scaledown = 1
  scale_up_desired   = 2
  scale_down_desired = 1

  ## Health Checks
  cpu_utilization_high_threshold_percent = 80
  cpu_utilization_low_threshold_percent  = 20
  health_check_type                      = "EC2"

  ## EBS Encryption
  ebs_encryption = true
  kms_key_arn    = module.kms_key.key_arn

  ## Service
  desired_count       = 2
  propagate_tags      = "SERVICE"
  scheduling_strategy = "REPLICA"
  weight              = 1
  base                = 1
  container_name      = "nginx"
  container_port      = 80

  ## Task Definition
  ec2_enabled  = true
  network_mode = "bridge"
  ipc_mode     = "task"
  pid_mode     = "task"
  cpu          = 2
  memory       = 300
}