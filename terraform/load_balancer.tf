resource "aws_lb_target_group" "autoscaleTG" {
  name     = "AutoscaleTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.hello_world.id
}

# Application load balancer
resource "aws_lb" "ecs_lb" {
  name               = "ecslb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_alb_sg.id]
  subnets            = aws_subnet.public.*.id
  enable_deletion_protection = false

}

# Listener for load balancer
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ecs_lb.arn
  port              = "80"
  protocol          = "HTTP"
  

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.autoscaleTG.arn
  }
}

resource "aws_lb_listener_rule" "test" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.autoscaleTG.arn
  }

  condition {
    path_pattern {
      values = ["/home/*"]
    }
  }
}

output "alb_dnsname" {
  value = aws_lb.ecs_lb.dns_name
}