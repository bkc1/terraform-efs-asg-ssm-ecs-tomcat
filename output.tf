output "alb_hostname" { value = "${aws_alb.myapp.dns_name}"}
output "asg_instance_id1" { value = "${aws_alb.myapp.dns_name}"}
