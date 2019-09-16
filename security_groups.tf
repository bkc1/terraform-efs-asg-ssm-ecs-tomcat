# ALB Security group
# This is the group you need to edit if you want to restrict access to your application
resource "aws_security_group" "lb" {
  name        = "${var.app_prefix}-ecs-alb"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.myapp.id
  tags = {
    Name = var.app_prefix
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "myapp_ecs" {
  name        = "${var.app_prefix}-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.myapp.id
  tags = {
    Name = var.app_prefix
  }

  # EFS/NFS access
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

