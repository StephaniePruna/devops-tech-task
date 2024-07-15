# Get the most recent AMI for an ECS-optimized Amazon Linux 2 instance
data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = data.aws_ami.amazon_linux_2.id
    iam_instance_profile = aws_iam_instance_profile.ec2_instance_role_profile.name
    security_groups      = [aws_security_group.ecs_ec2_sg.id]
    user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.hello_world_ecs_cluster.name} >> /etc/ecs/ecs.config;
      echo ECS_LOGLEVEL=error >> /etc/ecs/ecs.config
      echo ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=3h >> /etc/ecs/ecs.config
      echo ECS_DATADIR=/data/ >> /etc/ecs/ecs.config
      echo ECS_ENABLE_TASK_IAM_ROLE=true  >> /etc/ecs/ecs.config
      echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config
      echo ECS_ENABLE_TASK_ENI=true >> /etc/ecs/ecs.config
      echo ECS_AVAILABLE_LOGGING_DRIVERS="[\"journald\", \"json-file\",\"syslog\",\"awslogs\"]" >> /etc/ecs/ecs.config
      echo ECS_RESERVED_MEMORY=200 >> /etc/ecs/ecs.config
    EOF
  )
    instance_type        = "t2.micro"
}