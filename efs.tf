resource "aws_efs_file_system" "myapp" {
  creation_token = "${var.app_prefix}"

  tags = {
    Name = "${var.app_prefix}"
  }
}

resource "aws_efs_mount_target" "asg" {
  count           = "${var.az_count}"
  file_system_id  = "${aws_efs_file_system.myapp.id}"
  subnet_id       = "${element(aws_subnet.private.*.id, count.index)}"
  security_groups = ["${aws_security_group.myapp_ecs.id}"]
}
