resource "aws_service_discovery_private_dns_namespace" "myapp" {
  name        = "myapp.terraform.local"
  description = "myapp"
  vpc         = aws_vpc.myapp.id
}

resource "aws_service_discovery_service" "myapp" {
  name = "tomcat"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.myapp.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

