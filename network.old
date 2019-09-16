# Create a VPC to launch our instances into
resource "aws_vpc" "myapp" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags {
    Name = "${var.app_prefix}-${var.env}"
  }
}

# Sets search domain in DHCP options
resource "aws_vpc_dhcp_options" "dhcp_opts" {
  domain_name         = "${var.domain_name}"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags {
    Name              = "${aws_vpc.myapp.tags.Name}"
  }
}

# Applies DHCP options to VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.myapp.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_opts.id}"
  depends_on      = ["aws_vpc_dhcp_options.dhcp_opts"]
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "myapp" {
  vpc_id = "${aws_vpc.myapp.id}"
  tags {
    Name = "${aws_vpc.myapp.tags.Name}_internetGW"
  }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.myapp.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.myapp.id}"
  depends_on             = ["aws_internet_gateway.myapp"]
}

# Create a subnet to launch our instances into, defining the AZ
resource "aws_subnet" "myapp1" {
  availability_zone       = "${element(split(",", lookup(var.az, var.aws_region)),count.index)}"
  vpc_id                  = "${aws_vpc.myapp.id}"
  cidr_block              = "${var.subnet1}"
  map_public_ip_on_launch = true
  tags {
    Name = "${aws_vpc.myapp.tags.Name}-subnet-1"
  }
}

# Create second subnet for web nodes & load balancing across multiple AZs
resource "aws_subnet" "myapp2" {
  availability_zone       = "${element(split(",", lookup(var.az, var.aws_region)),count.index + 1)}"
  vpc_id                  = "${aws_vpc.myapp.id}"
  cidr_block              = "${var.subnet2}"
  map_public_ip_on_launch = true
  tags {
    Name = "${aws_vpc.myapp.tags.Name}-subnet-2"
  }
}

