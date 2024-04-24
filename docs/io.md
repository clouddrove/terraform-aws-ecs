## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_security\_group\_ids | Additional list of security groups that will be attached to the autoscaling group. | `list(string)` | `[]` | no |
| assign\_public\_ip | Assign a public IP address to the ENI (Fargate launch type only). Valid values are true or false. Default false. | `bool` | `false` | no |
| associate\_public\_ip\_address | Associate a public IP address with an instance in a VPC. | `bool` | `false` | no |
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
| listener\_certificate\_arn | The ARN of the SSL server certificate. Exactly one certificate is required if the protocol is HTTPS. | `string` | `""` | no |
| load\_balancers | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead. | `list(string)` | `[]` | no |
| managedby | ManagedBy, eg 'CloudDrove'. | `string` | `"hello@clouddrove.com"` | no |
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
| repository | Terraform current module repo | `string` | `""` | no |
| retention\_in\_days | The retention of cloud watch logs. | `number` | `30` | no |
| scale\_down\_desired | The number of Amazon EC2 instances that should be running in the group. | `number` | `0` | no |
| scale\_up\_desired | The number of Amazon EC2 instances that should be running in the group. | `number` | `0` | no |
| schedule\_enabled | AutoScaling Schedule resource | `bool` | `false` | no |
| scheduler\_down | What is the recurrency for scaling up operations ? | `string` | `"0 19 * * MON-FRI"` | no |
| scheduler\_up | What is the recurrency for scaling down operations ? | `string` | `"0 6 * * MON-FRI"` | no |
| scheduling\_strategy | The scheduling strategy to use for the service. The valid values are REPLICA and DAEMON. | `string` | `"REPLICA"` | no |
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

