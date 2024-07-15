resource "aws_ecs_cluster" "hello_world_ecs_cluster" {
  name = "${var.name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "hello_world_ecs_service" {
  name            = "${var.name}-ecs-service"
  cluster         = aws_ecs_cluster.hello_world_ecs_cluster.id
  task_definition = aws_ecs_task_definition.hello_world_ecs_task.arn
  desired_count   = var.container_count
  iam_role        = aws_iam_role.ecs_service_role.arn
  load_balancer {
      target_group_arn = aws_lb_target_group.autoscaleTG.arn
      container_name   = "${var.name}"
      container_port   = 80
  }
}

resource "aws_ecs_task_definition" "hello_world_ecs_task" {
  family                   = "${var.name}-ecs-task-family"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  task_role_arn            = aws_iam_role.ec2_instance_role.arn
  execution_role_arn       = aws_iam_role.ecs_service_role.arn
  container_definitions    = jsonencode([
    {
      name      = "${var.name}"
      image     = "381492132929.dkr.ecr.ap-southeast-2.amazonaws.com/hello-world-server:latest"
      cpu       = 200
      memory    = 200
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
        }
      ]
    },
  ])
}