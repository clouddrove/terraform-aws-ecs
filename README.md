<!-- This file was automatically generated by the `geine`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

<p align="center"> <img src="https://user-images.githubusercontent.com/50652676/62349836-882fef80-b51e-11e9-99e3-7b974309c7e3.png" width="100" height="100"></p>


<h1 align="center">
    Terraform AWS ECS
</h1>

<p align="center" style="font-size: 1.2rem;"> 
    Terraform module to create ECS on AWS.
     </p>

<p align="center">

<a href="https://www.terraform.io">
  <img src="https://img.shields.io/badge/Terraform-v0.15-green" alt="Terraform">
</a>
<a href="LICENSE.md">
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="Licence">
</a>


</p>
<p align="center">

<a href='https://facebook.com/sharer/sharer.php?u=https://github.com/clouddrove/terraform-aws-ecs'>
  <img title="Share on Facebook" src="https://user-images.githubusercontent.com/50652676/62817743-4f64cb80-bb59-11e9-90c7-b057252ded50.png" />
</a>
<a href='https://www.linkedin.com/shareArticle?mini=true&title=Terraform+AWS+ECS&url=https://github.com/clouddrove/terraform-aws-ecs'>
  <img title="Share on LinkedIn" src="https://user-images.githubusercontent.com/50652676/62817742-4e339e80-bb59-11e9-87b9-a1f68cae1049.png" />
</a>
<a href='https://twitter.com/intent/tweet/?text=Terraform+AWS+ECS&url=https://github.com/clouddrove/terraform-aws-ecs'>
  <img title="Share on Twitter" src="https://user-images.githubusercontent.com/50652676/62817740-4c69db00-bb59-11e9-8a79-3580fbbf6d5c.png" />
</a>

</p>
<hr>


We eat, drink, sleep and most importantly love **DevOps**. We are working towards strategies for standardizing architecture while ensuring security for the infrastructure. We are strong believer of the philosophy <b>Bigger problems are always solved by breaking them into smaller manageable problems</b>. Resonating with microservices architecture, it is considered best-practice to run database, cluster, storage in smaller <b>connected yet manageable pieces</b> within the infrastructure. 

This module is basically combination of [Terraform open source](https://www.terraform.io/) and includes automatation tests and examples. It also helps to create and improve your infrastructure with minimalistic code instead of maintaining the whole infrastructure code yourself.

We have [*fifty plus terraform modules*][terraform_modules]. A few of them are comepleted and are available for open source usage while a few others are in progress.




## Prerequisites

This module has a few dependencies: 

- [Terraform 0.13](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Go](https://golang.org/doc/install)
- [github.com/stretchr/testify/assert](https://github.com/stretchr/testify)
- [github.com/gruntwork-io/terratest/modules/terraform](https://github.com/gruntwork-io/terratest)







## Examples


**IMPORTANT:** Since the `master` branch used in `source` varies based on new modifications, we suggest that you use the release versions [here](https://github.com/clouddrove/terraform-aws-ecs/releases).


### Network Mode AWSVPC Example
Here is an example of how you can use this module in your inventory structure:
  ```hcl
  module "ecs" {
    source  = "clouddrove/ecs/aws"
    version = "0.15.0"
    ## Tags
    name        = "ecs-awsvpc"
    environment = "test"
    label_order = ["environment", "name"]
    enabled     = false      # set to true after VPC, Subnets, Security Groups, KMS Key and Key Pair gets created

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
  ```

### Network Mode BRIDGE Example
Here is an example of how you can use this module in your inventory structure:
  ```hcl
  module "ecs" {
    source = "git::https://github.com/clouddrove/terraform-aws-ecs.git?ref=tags/0.12.0"

    ## Tags
    name        = "ecs-bridge"
    environment = "test"
    label_order = ["environment", "name"]
    enabled     = false      # set to true after VPC, Subnets, Security Groups, KMS Key and Key Pair gets created

    ## Network
    vpc_id                        = module.vpc.vpc_id
    subnet_ids                    = module.subnets.private_subnet_id
    additional_security_group_ids = [module.sg_ssh.security_group_ids]

    ## EC2
    autoscaling_policies_enabled = true
    key_name                     = module.keypair.name
    image_id                     = "ami-001085c9389955bb6"
    instance_type                = "t3.medium"
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
    desired_count       = 6
    propagate_tags      = "TASK_DEFINITION"
    lb_subnet           = module.subnets.public_subnet_id
    scheduling_strategy = "REPLICA"
    container_name      = "nginx"
    container_port      = 80
    target_type         = "instance"

    ## Task Definition
    ec2_td_enabled           = true
    network_mode             = "bridge"
    ipc_mode                 = "task"
    pid_mode                 = "task"
    cpu                      = 512
    memory                   = 1024
    file_name                = "./td-ec2-bridge.json"
    container_log_group_name = "ec2-container-logs"
  }
  ```

### Fargate Example
Here is an example of how you can use this module in your inventory structure:
  ```hcl
  module "ecs" {
    source = "git::https://github.com/clouddrove/terraform-aws-ecs.git?ref=tags/0.12.0"

    ## Tags
    name        = "ecs-fargate"
    environment = "test"
    label_order = ["environment", "name"]
    enabled     = false      # set to true after VPC, Subnets, Security Groups, KMS Key and Key Pair gets created

    ## Network
    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.subnets.private_subnet_id

    ## EC2
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
    fargate_td_enabled       = true
    cpu                      = 512
    memory                   = 1024
    file_name                = "./td-fargate.json"
    container_log_group_name = "ec2-container-logs"
  }
  ```






## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_security\_group\_ids | Additional list of security groups that will be attached to the autoscaling group. | `list(string)` | `[]` | no |
| assign\_public\_ip | Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false. | `bool` | `false` | no |
| associate\_public\_ip\_address | Associate a public IP address with an instance in a VPC. | `bool` | `false` | no |
| attributes | Additional attributes (e.g. `1`). | `list(any)` | `[]` | no |
| autoscaling\_policies\_enabled | Whether to create `aws_autoscaling_policy` and `aws_cloudwatch_metric_alarm` resources to control Auto Scaling. | `bool` | `false` | no |
| base | The number of tasks, at a minimum, to run on the specified capacity provider. | `number` | `1` | no |
| cloudwatch\_prefix | The prefix of cloudwatch logs. | `string` | `""` | no |
| container\_log\_group\_name | Log group name for the container. | `string` | `"log-group"` | no |
| container\_name | The name of the container to associate with the load balancer (as it appears in a container definition). | `string` | `""` | no |
| container\_port | The port on the container to associate with the load balancer. | `number` | `80` | no |
| cpu | The number of cpu units used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `512` | no |
| delimiter | Delimiter to be used between `organization`, `environment`, `name` and `attributes`. | `string` | `"-"` | no |
| deployment\_maximum\_percent | The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. | `number` | `200` | no |
| deployment\_minimum\_healthy\_percent | The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment. | `number` | `100` | no |
| desired\_count | The number of instances of the task definition to place and keep running. | `number` | `0` | no |
| ebs\_encryption | Enables EBS encryption on the volume (Default: false). Cannot be used with snapshot\_id. | `bool` | `false` | no |
| ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `true` | no |
| ec2\_awsvpc\_enabled | AWSVPC network mode is enabled or not. | `bool` | `false` | no |
| ec2\_cluster\_enabled | Whether ec2 cluster is enabled or not. | `bool` | `false` | no |
| ec2\_service\_enabled | Whether EC2 launch type is enabled. | `bool` | `false` | no |
| ec2\_td\_enabled | Whether EC2 task definition is enabled. | `bool` | `false` | no |
| ecs\_settings\_enabled | Whether ecs setting is enabled or not. | `string` | `""` | no |
| enable\_ecs\_managed\_tags | Specifies whether to enable Amazon ECS managed tags for the tasks within the service. | `bool` | `false` | no |
| enabled | Whether to create the resources. Set to `false` to prevent the module from creating any resources. | `bool` | `false` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| fargate\_capacity\_provider\_simple | The name of the capacity provider. | `string` | `""` | no |
| fargate\_capacity\_provider\_spot | The name of the capacity provider. | `string` | `""` | no |
| fargate\_cluster\_cp | The name of the capacity provider. | `list(string)` | `[]` | no |
| fargate\_cluster\_enabled | Whether fargate cluster is enabled or not. | `bool` | `false` | no |
| fargate\_service\_enabled | Whether fargate is enabled or not. | `bool` | `false` | no |
| fargate\_td\_enabled | Whether fargate task definition is enabled. | `bool` | `false` | no |
| file\_name | File name for container definitions. | `string` | `""` | no |
| health\_check\_grace\_period\_seconds | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. | `number` | `360` | no |
| health\_check\_type | Controls how health checking is done. Valid values are `EC2` or `ELB`. | `string` | `"EC2"` | no |
| image\_id | The EC2 image ID to launch. | `string` | `""` | no |
| instance\_type | Instance type to launch. | `string` | `"t2.medium"` | no |
| ipc\_mode | The IPC resource namespace to be used for the containers in the task The valid values are host, task, and none. (It does not support for fargate launch type). | `string` | `"task"` | no |
| key\_name | The SSH key name that should be used for the instance. | `string` | `""` | no |
| kms\_key\_arn | AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set. | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | `[]` | no |
| lb\_security\_group | The LB security groups. | `string` | `""` | no |
| lb\_subnet | The subnet associated with the load balancer. | `list(string)` | `[]` | no |
| load\_balancers | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead. | `list(string)` | `[]` | no |
| managedby | ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'. | `string` | `"anmol@clouddrove.com"` | no |
| max\_size | The maximum size of the autoscale group. | `number` | `3` | no |
| max\_size\_scaledown | The maximum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `number` | `1` | no |
| memory | The amount (in MiB) of memory used by the task. If the requires\_compatibilities is FARGATE this field is required. | `number` | `1024` | no |
| memory\_reservation\_high\_threshold\_percent | The value against which the specified statistic is compared. | `number` | `75` | no |
| memory\_reservation\_low\_threshold\_percent | The value against which the specified statistic is compared. | `number` | `25` | no |
| min\_size | The minimum size of the autoscale group. | `number` | `0` | no |
| min\_size\_scaledown | The minimum size for the Auto Scaling group. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `number` | `0` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| network\_mode | The Docker networking mode to use for the containers in the task. The valid values are none, bridge, awsvpc, and host. | `string` | `"bridge"` | no |
| pid\_mode | The process namespace to use for the containers in the task. The valid values are host and task. (It does not support for fargate launch type). | `string` | `"task"` | no |
| platform\_version | The platform version on which to run your service. | `string` | `"LATEST"` | no |
| propagate\_tags | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are SERVICE and TASK\_DEFINITION. | `string` | `"SERVICE"` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/clouddrove/terraform-aws-ecs"` | no |
| retention\_in\_days | The retention of cloud watch logs. | `number` | `30` | no |
| scale\_down\_desired | The number of Amazon EC2 instances that should be running in the group. | `number` | `0` | no |
| scale\_up\_desired | The number of Amazon EC2 instances that should be running in the group. | `number` | `0` | no |
| schedule\_enabled | AutoScaling Schedule resource | `bool` | `false` | no |
| scheduler\_down | What is the recurrency for scaling up operations ? | `string` | `"0 19 * * MON-FRI"` | no |
| scheduler\_up | What is the recurrency for scaling down operations ? | `string` | `"0 6 * * MON-FRI"` | no |
| scheduling\_strategy | The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON. | `string` | `"REPLICA"` | no |
| security\_group\_ids | A list of associated security group IDs. | `list(string)` | `[]` | no |
| service\_lb\_security\_group | The service LB security groups. | `list(string)` | `[]` | no |
| spot\_enabled | Whether to create the spot instance. Set to `false` to prevent the module from creating any  spot instances. | `bool` | `false` | no |
| spot\_instance\_type | Sport instance type to launch. | `string` | `"t2.medium"` | no |
| spot\_max\_size | The maximum size of the spot autoscale group. | `number` | `3` | no |
| spot\_max\_size\_scaledown | The maximum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `number` | `1` | no |
| spot\_min\_size | The minimum size of the spot autoscale group. | `number` | `0` | no |
| spot\_min\_size\_scaledown | The minimum size for the Auto Scaling group of spot instances. Default 0. Set to -1 if you don't want to change the minimum size at the scheduled time. | `number` | `0` | no |
| spot\_price | The maximum hourly price you're willing to pay for the Spot Instances. | `number` | `1` | no |
| spot\_scale\_down\_desired | The number of Amazon EC2 instances that should be running in the group. | `number` | `0` | no |
| spot\_scale\_up\_desired | The number of Amazon EC2 instances that should be running in the group. | `number` | `0` | no |
| spot\_schedule\_enabled | AutoScaling Schedule resource for spot | `bool` | `false` | no |
| subnet\_ids | A list of subnet IDs to launch resources in. | `list(string)` | `[]` | no |
| tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(any)` | `{}` | no |
| target\_group\_arns | A list of aws\_alb\_target\_group ARNs, for use with Application Load Balancing. | `list(string)` | `[]` | no |
| target\_type | The target type for load balancer. | `string` | `""` | no |
| task\_role\_arn | The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services. | `string` | `""` | no |
| type | Type of deployment controller. Valid values: CODE\_DEPLOY, ECS. Default: ECS. | `string` | `"ECS"` | no |
| volume\_size | The size of ebs volume. | `number` | `50` | no |
| volume\_type | The type of volume. Can be `standard`, `gp2`, or `io1`. (Default: `standard`). | `string` | `"gp2"` | no |
| vpc\_id | VPC ID for the EKS cluster. | `string` | `""` | no |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"15m"` | no |
| weight\_simple | The relative percentage of the total number of launched tasks that should use the specified capacity provider. | `number` | `1` | no |
| weight\_spot | The relative percentage of the total number of launched tasks that should use the specified capacity provider. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| auto\_scaling\_tags | The tags of the autoscaling group |
| autoscaling\_group\_arn | The ARN for this AutoScaling Group |
| autoscaling\_group\_default\_cooldown | Time between a scaling activity and the succeeding scaling activity |
| autoscaling\_group\_desired\_capacity | The number of Amazon EC2 instances that should be running in the group |
| autoscaling\_group\_health\_check\_grace\_period | Time after instance comes into service before checking health |
| autoscaling\_group\_health\_check\_type | `EC2` or `ELB`. Controls how health checking is done |
| autoscaling\_group\_id | The autoscaling group id |
| autoscaling\_group\_max\_size | The maximum size of the autoscale group |
| autoscaling\_group\_min\_size | The minimum size of the autoscale group |
| autoscaling\_group\_name | The autoscaling group name |
| ec2\_cluster\_arn | The Amazon Resource Name (ARN) that identifies the cluster |
| ec2\_cluster\_id | The Amazon Resource Name (ARN) that identifies the cluster |
| ec2\_cluster\_name | The name of the ECS cluster |
| ec2\_service\_cluster | The Amazon Resource Name (ARN) of cluster which the service runs on |
| ec2\_service\_desired\_count | The number of instances of the task definition |
| ec2\_service\_iam\_role | The ARN of IAM role used for LB |
| ec2\_service\_id | The Amazon Resource Name (ARN) that identifies the service |
| ec2\_service\_name | The name of the service |
| ec2\_td\_arn | Full ARN of the Task Definition (including both family and revision). |
| ec2\_td\_family | The family of the Task Definition. |
| ec2\_td\_revision | The revision of the task in a particular family. |
| ecs\_tags | The tags of the autoscaling group |
| fargate\_cluster\_arn | The Amazon Resource Name (ARN) that identifies the cluster |
| fargate\_cluster\_id | The Amazon Resource Name (ARN) that identifies the cluster |
| fargate\_cluster\_name | The name of the ECS cluster |
| fargate\_service\_cluster | The Amazon Resource Name (ARN) of cluster which the service runs on |
| fargate\_service\_desired\_count | The number of instances of the task definition |
| fargate\_service\_id | The Amazon Resource Name (ARN) that identifies the service |
| fargate\_service\_name | The name of the service |
| fargate\_td\_arn | Full ARN of the Task Definition (including both family and revision). |
| fargate\_td\_family | The family of the Task Definition. |
| fargate\_td\_revision | The revision of the task in a particular family. |
| launch\_configuration\_arn | The ARN of the launch configuration |
| launch\_configuration\_id | The ID of the launch configuration |
| service\_tags | The tags of the service |
| spot\_autoscaling\_group\_arn | The ARN for this AutoScaling Group |
| spot\_autoscaling\_group\_id | The spot autoscaling group id |
| spot\_autoscaling\_group\_name | The spot autoscaling group name |
| td\_tags | The tags of task definition |




## Testing
In this module testing is performed with [terratest](https://github.com/gruntwork-io/terratest) and it creates a small piece of infrastructure, matches the output like ARN, ID and Tags name etc and destroy infrastructure in your AWS account. This testing is written in GO, so you need a [GO environment](https://golang.org/doc/install) in your system. 

You need to run the following command in the testing folder:
```hcl
  go test -run Test
```



## Feedback 
If you come accross a bug or have any feedback, please log it in our [issue tracker](https://github.com/clouddrove/terraform-aws-ecs/issues), or feel free to drop us an email at [hello@clouddrove.com](mailto:hello@clouddrove.com).

If you have found it worth your time, go ahead and give us a ★ on [our GitHub](https://github.com/clouddrove/terraform-aws-ecs)!

## About us

At [CloudDrove][website], we offer expert guidance, implementation support and services to help organisations accelerate their journey to the cloud. Our services include docker and container orchestration, cloud migration and adoption, infrastructure automation, application modernisation and remediation, and performance engineering.

<p align="center">We are <b> The Cloud Experts!</b></p>
<hr />
<p align="center">We ❤️  <a href="https://github.com/clouddrove">Open Source</a> and you can check out <a href="https://github.com/clouddrove">our other modules</a> to get help with your new Cloud ideas.</p>

  [website]: https://clouddrove.com
  [github]: https://github.com/clouddrove
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://twitter.com/clouddrove/
  [email]: https://clouddrove.com/contact-us.html
  [terraform_modules]: https://github.com/clouddrove?utf8=%E2%9C%93&q=terraform-&type=&language=
