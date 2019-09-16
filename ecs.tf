resource "aws_ecs_cluster" "my_cluster" {
  name       = "${var.app_prefix}"
  tags = {
    Name = "${var.app_prefix}"
  }
}

data "template_file" "task_definition" {
  template = "${file("task-definition.json")}"
  vars = {
    image               = "${var.image_name}:${var.image_tag}"
    container_name      = "tomcat"
    log_group_region    = "${var.aws_region}"
    log_group_name      = "${var.app_prefix}"
    log_stream_prefix   = "${var.app_prefix}"
    hostport1           = "${var.app_port}"
    containerport1      = "${var.app_port}"
  }
}

data "aws_ecs_task_definition" "my_tomcat" {
  task_definition = "${aws_ecs_task_definition.my_tomcat.family}"
}

resource "aws_ecs_task_definition" "my_tomcat" {
  family                = "tomcat"
  container_definitions = "${data.template_file.task_definition.rendered}"
  network_mode          = "awsvpc"
  tags = {
    Name = "${var.app_prefix}"
  }
}


resource "aws_ecs_service" "my_tomcat" {
  name            = "${var.app_prefix}"
  cluster         = "${aws_ecs_cluster.my_cluster.id}"
  task_definition = "${aws_ecs_task_definition.my_tomcat.family}:${max("${aws_ecs_task_definition.my_tomcat.revision}", "${data.aws_ecs_task_definition.my_tomcat.revision}")}"
  desired_count   = 2
#  iam_role        = "${aws_iam_role.myapp.arn}"
  depends_on      = ["aws_cloudwatch_log_group.my_tomcat", "aws_alb_listener.front_end"]
  placement_constraints {
    type  = "distinctInstance"
  }
  load_balancer {
    target_group_arn = "${aws_alb_target_group.myapp.arn}"
    container_name   = "tomcat"
    container_port   = "${var.app_port}"
  }
  network_configuration {
    security_groups = ["${aws_security_group.myapp_ecs.id}"]
    subnets         = ["${aws_subnet.private.*.id}"]
  }
#  tags = {
#    Name = "${var.app_prefix}"
#  }

}

resource "aws_cloudwatch_log_group" "my_tomcat" {
  name = "${var.app_prefix}"
}

