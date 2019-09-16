# Specify the provider and access details
provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "myapp" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

#Amazon Linux 2 ECS optimizied
data "aws_ami" "ecs" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-*"]
  }

  #  name_regex  = "\\S*ecs-optimized"
  owners = ["amazon"]
}

