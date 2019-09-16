resource "aws_alb" "myapp" {
  name            = "${var.app_prefix}-ecs"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.lb.id}"]
  tags = {
    Environment = "${var.app_prefix}"
  }
}

resource "aws_alb_target_group" "myapp" {
  name        = "${var.app_prefix}-ecs"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.myapp.id}"
  target_type = "ip"
  tags = {
    Environment = "${var.app_prefix}"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.myapp.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.myapp.id}"
    type             = "forward"
  }
}
