variable "public_key_path" {
  description = "Enter path to the public key"
  default     = "keys/mykey.pub"
}

variable "key_name" {
  description = "Enter name of private key"
  default     = "mykey"
}

variable "aws_region" {
  description = "AWS region to launch servers"
  default     = "us-west-2"
}

variable "app_prefix" {
  description = "Application abbreviation/prefix"
  default     = "myapp"
}

variable "az_count" {
  default = 2
}

#user-data cloud-init script
variable "cloud_init" {
  default = "bootstrap.sh"
}

variable "env" {
  default = "dev"
}

variable "domain_name" {
  default = "aws-dev.example.io"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/21"
}

variable "image_name" {
  default = "tomcat"
}

variable "image_tag" {
  default = "latest"
}

variable "app_port" {
  default = 8080
}

