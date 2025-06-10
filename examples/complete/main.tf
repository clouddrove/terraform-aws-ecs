provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
  name   = "clouddrove-${basename(path.cwd)}"

  vpc_cidr_block        = module.vpc.vpc_cidr_block
  additional_cidr_block = "172.16.0.0/16"
  environment           = "test"
  label_order           = ["name", "environment"]

  container_name = "ecsdemo-frontend"
  container_port = 3000

  tags = {
    Name       = local.name
    environment = local.environment
    label_order = local.label_order
    Repository = "https://github.com/clouddrove/terraform-aws-ecs"
  }
}

################################################################################
# Cluster
################################################################################

module "ecs" {
  source = "../../"

  cluster_name = local.name

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

  services = {
    ecsdemo-frontend = {
      cpu    = 1024
      memory = 4096

      # Container definition(s)
      container_definitions = {

        fluent-bit = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = nonsensitive(data.aws_ssm_parameter.fluentbit.value)
          firelens_configuration = {
            type = "fluentbit"
          }
          memory_reservation = 50
        }

        (local.container_name) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"

          health_check = {
            command = ["CMD-SHELL", "curl -f http://localhost:${local.container_port}/health || exit 1"]
          }

          port_mappings = [
            {
              name          = local.container_name
              containerPort = local.container_port
              hostPort      = local.container_port
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          dependencies = [{
            containerName = "fluent-bit"
            condition     = "START"
          }]

          enable_cloudwatch_logging = false
          log_configuration = {
            logDriver = "awsfirelens"
            options = {
              Name                    = "firehose"
              region                  = local.region
              delivery_stream         = "my-stream"
              log-driver-buffer-limit = "2097152"
            }
          }
          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.this.arn
        service = {
          client_alias = {
            port     = local.container_port
            dns_name = local.container_name
          }
          port_name      = local.container_name
          discovery_name = local.container_name
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.lb.main_target_group_arn
          container_name   = local.container_name
          container_port   = local.container_port
        }
      }

      tasks_iam_role_name        = "${local.name}-tasks"
      tasks_iam_role_description = "Example tasks IAM role for ${local.name}"
      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]

      subnet_ids = module.subnets.private_subnet_id
      security_group_rules = {
        alb_ingress_3000 = {
          type                     = "ingress"
          from_port                = local.container_port
          to_port                  = local.container_port
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.sg_lb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

data "aws_ssm_parameter" "fluentbit" {
  name = "/aws/service/aws-for-fluent-bit/stable"
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.name
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}

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
}
