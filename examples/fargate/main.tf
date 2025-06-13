provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
  name   = "clouddrove-${basename(path.cwd)}"

  vpc_cidr_block        = module.vpc.vpc_cidr_block
  additional_cidr_block = "172.16.0.0/16"
  environment           = "test"

  container_name = "nginx"
  container_port = 80
}

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

################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "../../modules/cluster"

  cluster_name = local.name
  cluster_configuration = {
    managed_storage_configuration = {
      kms_key_id = module.kms_key.key_arn
    }
  }

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  depends_on = [ module.kms_key ]
}

################################################################################
# Service and Task Definition
################################################################################

module "ecs_service" {
  source = "../../modules/service"

  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 1024
  memory = 4096

  # Enables ECS Exec
  enable_execute_command = true
  assign_public_ip       = true

  # Task definition(s)
  container_definitions = {

    nginx = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "nginx:latest"
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]
      memory_reservation = 50
      user               = "0"

      readonly_root_filesystem = false

      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/aws/ecs/${local.name}/nginx"
          awslogs-region        = local.region
          awslogs-stream-prefix = "nginx"
        }
      }

      linux_parameters = {
        capabilities = {
          add  = []
          drop = ["NET_RAW"]
        }
      }
    }
  }

##### Enabling DNS Namespace for Service Connect and Service Discovery #####
  enable_private_dns_namespace = true
  service_connect_configuration = {
    service = {
      client_alias = {
        port     = local.container_port
        dns_name = local.container_name
      }
      port_name      = local.container_name
      discovery_name = local.container_name
    }
  }

##### vpc id for dns namespace attached to service registries #####
  dns_namespace_vpc_id = module.vpc.vpc_id
  service_registries = {
    container_name = local.container_name
    # container_port = local.container_port
  }

  load_balancer = {
    service = {
      target_group_arn = module.lb.main_target_group_arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = module.subnets.private_subnet_id
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.lb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # depends_on = [ aws_service_discovery_private_dns_namespace.this ]

  service_tags = {
    "ServiceTag" = "Tag on service level"
  }
}

################################################################################
# Standalone Task Definition (w/o Service)
################################################################################

module "ecs_task_definition" {
  source = "../../modules/service"

  # Service
  name           = "${local.name}-standalone"
  cluster_arn    = module.ecs_cluster.arn
  create_service = false

  # Task Definition
  volume = {
    ex-vol = {}
  }

  runtime_platform = {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  # Container definition(s)
  container_definitions = {
    al2023 = {
      image = "public.ecr.aws/amazonlinux/amazonlinux:2023-minimal"

      mount_points = [
        {
          sourceVolume  = "ex-vol",
          containerPath = "/var/www/ex-vol"
        }
      ]

      command    = ["echo hello world"]
      entrypoint = ["/usr/bin/sh", "-c"]
    }
  }

  subnet_ids = module.subnets.private_subnet_id

  security_group_rules = {
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

################################################################################
# Supporting Resources
################################################################################

# resource "aws_service_discovery_private_dns_namespace" "this" {
#   name        = local.name
#   vpc         = module.vpc.vpc_id
#   description = "Private namespace for ${local.name}"
# }

# resource "aws_service_discovery_service" "this" {
#   name = local.name

#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.this.id
#     routing_policy = "MULTIVALUE"
#     dns_records {
#       type = "A"
#       ttl  = 10
#     }
#   }

#   health_check_custom_config {
#     failure_threshold = 1
#   }
# }

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

module "lb" {
  source  = "clouddrove/alb/aws"
  version = "2.0.0"

  name                       = "alb"
  load_balancer_type         = "application"
  enable                     = true
  internal                   = true
  enable_deletion_protection = false
  with_target_group          = true
  https_enabled              = true
  http_enabled               = true
  subnets                    = module.subnets.public_subnet_id
  target_id                  = []
  vpc_id                     = module.vpc.vpc_id
  listener_certificate_arn   = module.acm.arn

  https_port        = 443
  listener_type     = "forward"
  target_group_port = 80
  target_groups = [
    {
      backend_protocol     = "HTTP"
      backend_port         = 80
      target_type          = "ip"
      deregistration_delay = 300
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  ]
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
  nat_gateway_enabled = true
  availability_zones  = ["eu-west-1a", "eu-west-1b"]
  vpc_id              = module.vpc.vpc_id
  cidr_block          = module.vpc.vpc_cidr_block
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block

  private_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]

  private_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}
