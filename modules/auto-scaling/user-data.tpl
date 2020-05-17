#!/bin/bash

yum update -y && yum install -y awslogs jq aws-cli wget vim curl ecs-init

service docker start

echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs","syslog","none"]' >> /etc/ecs/ecs.config
echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_ENI=true >> /etc/ecs/ecs.config

start ecs