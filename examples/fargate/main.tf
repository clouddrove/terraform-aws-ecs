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
  version = "2.0.1"

  name                = "subnets"
  repository          = "https://github.com/clouddrove/terraform-aws-subnet"
  environment         = "test"
  label_order         = ["name", "environment"]
  # nat_gateway_enabled = true
  availability_zones  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
}

# ################################################################################
# Security Groups module call
################################################################################

module "sg_lb" {
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

####----------------------------------------------------------------------------------
## This terraform module is used for requesting or importing SSL/TLS certificate with validation.
####----------------------------------------------------------------------------------
module "acm" {
  source  = "clouddrove/acm/aws"
  version = "1.4.1"

  name        = "certificate"
  environment = "test"
  label_order = ["name", "environment"]

  enable_aws_certificate    = true
  domain_name               = "clouddrove.ca"
  subject_alternative_names = ["*.clouddrove.ca"]
  validation_method         = "DNS"
  enable_dns_validation     = false
}

##-----------------------------------------------------------------------------
## ecs module call.
##-----------------------------------------------------------------------------
module "ecs" {
  source = "../../"

  ## Tags
  name        = "ecs-fargate"
  repository  = "https://github.com/clouddrove/terraform-aws-ecs"
  environment = "test"
  label_order = ["name", "environment"]
  enabled     = true # set to true after VPC, Subnets and Security Groups gets created

  ## Network
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_id

  ## EC2
  lb_security_group        = module.sg_lb.security_group_id
  lb_subnet                = module.subnets.public_subnet_id
  listener_certificate_arn = module.acm.arn

  ## Fargate Cluster
  fargate_cluster_enabled = true
  ecs_settings_enabled    = "enabled"
  fargate_cluster_cp      = ["FARGATE", "FARGATE_SPOT"]

  ## Service
  fargate_service_enabled          = true
  desired_count                    = 4
  assign_public_ip                 = true
  propagate_tags                   = "TASK_DEFINITION"
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
  fargate_td_enabled       = true
  cpu                      = 512
  network_mode             = "bridge"
  memory                   = 1024
  file_name                = "./td-fargate.json"
  container_log_group_name = "fargate-container-logs"
}