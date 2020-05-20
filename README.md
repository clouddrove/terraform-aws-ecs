# Points To Be Care Of Before Applying ECS Terraform Module

1. Make sure you have tick mark all the resources in `Amazon ECS ARN and resource ID settings` in ECS > Account Settings in the particular region where you are deploying this module. These checks are required because ECS service supports new opt-in feature for creation of service.

2. I took `m5.large` instance type in `_example/ec2-network-mode-awsvpc/example.tf` because awsvpc network mode supports only these instance types - [Link](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-eni.html#eni-trunking-supported-instance-types)

3. I took container port `80` in `example.tf` files as this container port should match the container port in `modules/task-definition/templates` JSON files as because this port will get mapped to the load balancer block in `modules/service/main.tf` in `aws_ecs_service` resource and same with container name also. If you want to change it then change in both - `template files` and `example.tf` files.

4. Never set `assign_public_ip = true` in `_example/ec2-network-mode-awsvpc/example.tf` because `awsvpc` network does not support ENI's with public IP address in EC2 launch type.

5. The `awslogs-group` in `modules/task-definition/templates` should match the cloud watch log group name which is getting created in `modules/task-definition/main.tf` file otherwise the task will not run on the container instance.

6. Never include `ipc_mode` and `pic_mode` in `modules/task-definition/main.tf` fargate ecs service resource because fargate does not support it.

7. In `_example/fargate/example.tf` the variable `assign_public_ip = true` is set because fargate requires this variable as true to assign tasks.

8. In `example.tf` files the `volume_size = 8` because when auto scaling group launch an instance then it creates an additional volume of size 22 as this size is acquired by docker and ECS agent to launch container onto the EC2 instance.

9. Never mention `base = var.base` in `modules/service/main.tf` on fargate ecs service resource of `capacity_provider_strategy` first column because base is mentioned only one time in any one `capacity_provider_strategy` block. Reference to this - [Link](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cluster-capacity-providers.html)

10. If you want to change the `CPU` and `Memory` of task and container definition, please make sure that the size for task should be greater than container definition otherwise it will give error.

## Reference Links

[AWS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)