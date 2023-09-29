##---------------------------------------------------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
##--------------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-west-1"
}

locals {
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  additional_cidr_block = "172.16.0.0/16"
}
##---------------------------------------------------------------------------------------------------------------------------
## A key pair is a combination of a public key that is used to encrypt data and a private key that is used to decrypt data.
##--------------------------------------------------------------------------------------------------------------------------
module "keypair" {
  source  = "clouddrove/keypair/aws"
  version = "1.3.1"

  name                       = "key"
  environment                = "test"
  label_order                = ["environment", "name"]
  public_key                 = ""
  create_private_key_enabled = true
  enable_key_pair            = true
}

##---------------------------------------------------------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
##--------------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  name        = "vpc"
  repository  = "https://github.com/clouddrove/terraform-aws-vpc"
  environment = "test"
  label_order = ["name", "environment"]
  cidr_block  = "10.10.0.0/16"
}

##-----------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
##-----------------------------------------------------
module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.0"

  name                = "subnets"
  repository          = "https://github.com/clouddrove/terraform-aws-subnet"
  environment         = "test"
  label_order         = ["name", "environment"]
  nat_gateway_enabled = true
  availability_zones  = ["eu-west-1a", "eu-west-1b"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
}

# ################################################################################
# Security Groups module call
################################################################################

module "ssh" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = "ssh"
  environment = "test"
  label_order = ["name", "environment"]
  vpc_id      = module.vpc.vpc_id
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block, local.additional_cidr_block]
    description = "Allow ssh traffic."
  }]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block, local.additional_cidr_block]
    description = "Allow ssh outbound traffic."
  }]
}
#tfsec:ignore:aws-ec2-no-public-egress-sgr
module "http_https" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = "http-https"
  environment = "test"
  label_order = ["name", "environment"]

  vpc_id = module.vpc.vpc_id
  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
      cidr_blocks = [local.vpc_cidr_block]
      description = "Allow http traffic."
    },
    {
      rule_count  = 3
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
      cidr_blocks = [local.vpc_cidr_block]
      description = "Allow https traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count       = 1
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all traffic."
    }
  ]
}

##-----------------------------------------------------
## AWS Key Management Service (AWS KMS) lets you create, manage, and control cryptographic keys across your applications and AWS services.
##-----------------------------------------------------
module "kms_key" {
  source  = "clouddrove/kms/aws"
  version = "1.3.1"

  name                     = "kms"
  repository               = "https://github.com/clouddrove/terraform-aws-kms"
  environment              = "test"
  label_order              = ["name", "environment"]
  enabled                  = true
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

####----------------------------------------------------------------------------------
## This terraform module is used for requesting or importing SSL/TLS certificate with validation.
####----------------------------------------------------------------------------------
module "acm" {
  source  = "clouddrove/acm/aws"
  version = "1.3.0"

  name        = "certificate"
  environment = "test"
  label_order = ["name", "environment"]

  enable_aws_certificate    = true
  enable_dns_validation     = false
  domain_name               = "clouddrove.ca"
  subject_alternative_names = ["*.clouddrove.ca"]
  validation_method         = "DNS"
}

##-----------------------------------------------------------------------------
## ecs module call.
##-----------------------------------------------------------------------------
module "ecs" {
  source = "../../"

  ## Tags
  name        = "ecs-awsvpc"
  repository  = "https://github.com/clouddrove/terraform-aws-ecs"
  environment = "test"
  label_order = ["name", "environment"]
  enabled     = true # set to true after VPC, Subnets, Security Groups, KMS Key and Key Pair gets created

  ## Network
  vpc_id                        = module.vpc.vpc_id
  subnet_ids                    = module.subnets.private_subnet_id
  additional_security_group_ids = ["${module.ssh.security_group_id}", "${module.http_https.security_group_id}"]
  listener_certificate_arn      = module.acm.arn

  ## EC2
  autoscaling_policies_enabled = false
  key_name                     = module.keypair.name
  image_id                     = "ami-001085c9389955bb6"
  instance_type                = "t3.medium"
  min_size                     = 1
  max_size                     = 3
  volume_size                  = 8
  lb_security_group            = module.ssh.security_group_id
  service_lb_security_group    = [module.http_https.security_group_id]
  cloudwatch_prefix            = "ecs-logs"

  ## ECS Cluster
  ec2_cluster_enabled  = true
  ecs_settings_enabled = "enabled"

  ## Schedule
  scheduler_down          = "0 19 * * MON-FRI"
  scheduler_up            = "0 6 * * MON-FRI"
  schedule_enabled        = true
  spot_schedule_enabled   = true
  min_size_scaledown      = 0
  max_size_scaledown      = 1
  scale_up_desired        = 2
  scale_down_desired      = 1
  spot_min_size_scaledown = 0
  spot_max_size_scaledown = 1
  spot_scale_up_desired   = 2
  spot_scale_down_desired = 1

  ## Spot
  spot_enabled       = true
  spot_min_size      = 1
  spot_max_size      = 3
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
  lb_subnet           = module.subnets.private_subnet_id
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
