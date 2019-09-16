# Fetch AZs in the current region
data "aws_availability_zones" "myapp" {
}

resource "aws_vpc" "myapp" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.app_prefix
  }
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.myapp.cidr_block, 4, count.index)
  availability_zone = data.aws_availability_zones.myapp.names[count.index]
  vpc_id            = aws_vpc.myapp.id
  tags = {
    Name = "${aws_vpc.myapp.tags.Name}-private${count.index}"
  }
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.myapp.cidr_block, 4, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.myapp.names[count.index]
  vpc_id                  = aws_vpc.myapp.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${aws_vpc.myapp.tags.Name}-public${count.index}"
  }
}

# IGW for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myapp.id
  tags = {
    Name = "${aws_vpc.myapp.tags.Name}-IGW"
  }
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.myapp.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "gw" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "gw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gw.*.id, count.index)
  tags = {
    Name = "${aws_vpc.myapp.tags.Name}-NATGW"
  }
}

# Create a new route table for the private subnets
# And make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.myapp.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }
  tags = {
    Name = var.app_prefix
  }
}

# Explicitely associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

# Sets search domain in DHCP options
resource "aws_vpc_dhcp_options" "dhcp_opts" {
  domain_name         = var.domain_name
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    Name = var.app_prefix
  }
}

# Applies DHCP options to VPC
resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.myapp.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_opts.id
  depends_on      = [aws_vpc_dhcp_options.dhcp_opts]
}

