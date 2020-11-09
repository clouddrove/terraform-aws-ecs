provider "aws" {
  region = "eu-west-1"
}

module "keypair" {
  source          = "clouddrove/keypair/aws"
  version         = "0.13.0"
  public_key      = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDfjNc4A+atuEBaElnpQqFkBFgGc+kCslpXh/aKETl1Wh95tOy9IWHomegVxKB44OvB5s6I6HFwRa8MCpcAUnW3vD7hBwOv+PgJ0ZFUGYrl71doDHsWtfgoRhrKlhk2jjS7gOZrrYK2vg0859knhrmRQEm6snqFdZ6bLc6R/r0htgtgUx9mESZHfupL/lylOjBiEboQxpo1lp2MKEmksv5q+8A60ZN+mTEj6M4Zmbiw7ypGjcK8utgOyoJ58uWIMt76VW46M6FIGVymwnqBm5PUgThzTPhwVpIc4kTw2Ko1CF4l8fhHNHr698NNTkpol5QvFiBZIgbTGF9RBJyYpGN1XupY4UCrwLBFb5Sigu42lCfb2/wpuAPk5LpoUhdvrDYyzxMdFy0AhIs+3my9D5jNs2rHywoYzcGfrEwi8tLHRqaV+nOI4URk7GenzAQWbUeKwosgSyVv4XnAFrtHMx2oUN5iqAMwFeZH67gw9BkATiF0ZhExCHGILcLZTNJP2N0= anmol@clouddrove-Lenov"
  key_name        = "main-key"
  enable_key_pair = true
  environment     = "test"
}

module "vpc" {
  source      = "clouddrove/vpc/aws"
  version     = "0.13.0"
  name        = "vpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  vpc_enabled = true

  cidr_block = "10.10.0.0/16"
}

module "subnets" {
  source      = "clouddrove/subnet/aws"
  version     = "0.13.0"
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
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
}

module "sg_ssh" {
  source      = "clouddrove/security-group/aws"
  version     = "0.13.0"
  name        = "sg-ssh"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["49.36.129.122/32", module.vpc.vpc_cidr_block]
  allowed_ports = [22]
}

module "sg_lb" {
  source      = "clouddrove/security-group/aws"
  version     = "0.13.0"
  name        = "sg-lb"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]

  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["0.0.0.0/0"]
  allowed_ports = [80]
}

module "kms_key" {
  source      = "clouddrove/kms/aws"
  version     = "0.13.0"
  name        = "kms"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  enabled     = true

  description              = "KMS key for ecs"
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
  name        = "ecs-awsvpc"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "application", "name"]
  enabled     = true # set to true after VPC, Subnets, Security Groups, KMS Key and Key Pair gets created

  ## Network
  vpc_id                        = module.vpc.vpc_id
  subnet_ids                    = module.subnets.private_subnet_id
  additional_security_group_ids = [module.sg_ssh.security_group_ids]

  ## EC2
  autoscaling_policies_enabled = true
  key_name                     = module.keypair.name
  image_id                     = "ami-001085c9389955bb6"
  instance_type                = "m5.large"
  min_size                     = 1
  max_size                     = 3
  volume_size                  = 8
  lb_security_group            = module.sg_lb.security_group_ids
  service_lb_security_group    = [module.sg_lb.security_group_ids]
  cloudwatch_prefix            = "ecs-logs"

  ## ECS Cluster
  ec2_cluster_enabled  = true
  ecs_settings_enabled = "enabled"

  ## Schedule
  scheduler_down = "0 19 * * MON-FRI"
  scheduler_up   = "0 6 * * MON-FRI"

  schedule_enabled   = true
  min_size_scaledown = 0
  max_size_scaledown = 1
  scale_up_desired   = 2
  scale_down_desired = 1

  spot_schedule_enabled   = true
  spot_min_size_scaledown = 0
  spot_max_size_scaledown = 1
  spot_scale_up_desired   = 2
  spot_scale_down_desired = 1

  ## Spot
  spot_enabled  = true
  spot_min_size = 1
  spot_max_size = 3

  spot_price         = "0.10"
  spot_instance_type = "m5.xlarge"

  ## Health Checks
  memory_reservation_high_threshold_percent = 75
  memory_reservation_low_threshold_percent  = 50
  health_check_type                         = "EC2"

  ## EBS Encryption
  ebs_encryption = true
  kms_key_arn    = module.kms_key.key_arn

  ## Service
  ec2_service_enabled = true
  ec2_awsvpc_enabled  = true
  desired_count       = 10
  propagate_tags      = "TASK_DEFINITION"
  lb_subnet           = module.subnets.public_subnet_id
  scheduling_strategy = "REPLICA"
  container_name      = "nginx"
  container_port      = 80
  target_type         = "ip"

  ## Task Definition
  ec2_td_enabled           = true
  network_mode             = "awsvpc"
  ipc_mode                 = "task"
  pid_mode                 = "task"
  cpu                      = 512
  memory                   = 1024
  file_name                = "./td-ec2-awsvpc.json"
  container_log_group_name = "ec2-container-logs"
}