#!/bin/bash

yum update -y && yum install -y awslogs jq aws-cli wget vim curl ecs-init

service docker start

echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs","syslog","none"]' >> /etc/ecs/ecs.config
echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_ENI=true >> /etc/ecs/ecs.config

cat > /etc/awslogs/awslogs.conf <<- EOF

[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/dmesg]
file = /var/log/dmesg
log_group_name = ${cloudwatch_prefix}/var/log/dmesg
log_stream_name = ${cluster_name}/{container_instance_id}

[/var/log/messages]
file = /var/log/messages
log_group_name = ${cloudwatch_prefix}/var/log/messages
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %b %d %H:%M:%S

[/var/log/docker]
file = /var/log/docker
log_group_name = ${cloudwatch_prefix}/var/log/docker
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%S.%f

[/var/log/ecs/ecs-init.log]
file = /var/log/ecs/ecs-init.log
log_group_name = ${cloudwatch_prefix}/var/log/ecs/ecs-init.log
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/ecs-agent.log]
file = /var/log/ecs/ecs-agent.log
log_group_name = ${cloudwatch_prefix}/var/log/ecs/ecs-agent.log
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

[/var/log/ecs/audit.log]
file = /var/log/ecs/audit.log
log_group_name = ${cloudwatch_prefix}/var/log/ecs/audit.log
log_stream_name = ${cluster_name}/{container_instance_id}
datetime_format = %Y-%m-%dT%H:%M:%SZ

EOF

# Set the region to send CloudWatch Logs data to (the region where the container instance is located)
region=$(curl 169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//')
sed -i -e "s/region = us-east-1/region = $region/g" /etc/awslogs/awscli.conf

# Set the ip address of the node
container_instance_id=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
sed -i -e "s/{container_instance_id}/$container_instance_id/g" /etc/awslogs/awslogs.conf

cat > /etc/init/awslogjob.conf <<- EOF

#upstart-job
description "Configure and start CloudWatch Logs agent on Amazon ECS container instance"
author "Amazon Web Services"
start on started ecs
script
	exec 2>>/var/log/ecs/cloudwatch-logs-start.log
	set -x

	until curl -s http://localhost:51678/v1/metadata
	do
		sleep 1
	done

	service awslogs start
	chkconfig awslogs on
end script

EOF

start ecs

instance_role_arn=$(curl http://169.254.169.254/latest/meta-data/iam/info | jq -r '. | .InstanceProfileArn' | awk -F/ '{print $NF}')

aws ecs put-account-setting --name awsvpcTrunking --value enabled --principal-arn $instance_role_arn --region $region