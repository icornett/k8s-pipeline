# Define DataSources
data "aws_vpc" "selected" {
  id = "${aws_vpc.vpc.id}"
}

data "aws_availability_zones" "all" {}

data "aws_region" "current" {
  current = true
}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidrBlock}"

  tags {
    Name = "${var.project_name}-vpc-${var.environmentName}"
  }

  lifecycle {
    #    prevent_destroy = true
  }
}

# Create main subnet for network - balance
resource "aws_subnet" "subnet" {
  count             = "${length(data.aws_availability_zones.all.names)}"
  vpc_id            = "${data.aws_vpc.selected.id}"
  availability_zone = "${element(data.aws_availability_zones.all.names, count.index)}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.selected.cidr_block, 8, count.index + 1)}"

  lifecycle {
    #    prevent_destroy = true
  }

  tags {
    Name = "${var.project_name}-public-subnet-${var.environmentName}-${count.index}"
  }
}

# Create private network for BE
resource "aws_subnet" "be_subnet" {
  count             = "${length(data.aws_availability_zones.all.names)}"
  vpc_id            = "${data.aws_vpc.selected.id}"
  availability_zone = "${element(data.aws_availability_zones.all.names, count.index)}"
  cidr_block        = "${cidrsubnet(data.aws_vpc.selected.cidr_block, 8, count.index + 100)}"

  lifecycle {
    #    prevent_destroy = true
  }

  tags {
    Name = "${var.project_name}-private-subnet-${var.environmentName}-${count.index}"
  }
}

# Allow Internet connectivity
resource "aws_internet_gateway" "${var.project_name}-gw" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "${var.project_name}-inetgw-${var.environmentName}"
  }
}

# Add FE subnets to default route table
resource "aws_route_table_association" "${var.project_name}" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.subnet.*.id, count.index)}"
  route_table_id = "${aws_vpc.vpc.default_route_table_id}"
}

# Add route to internet gateway for outbound
resource "aws_route" "allow_outbound" {
  route_table_id         = "${aws_vpc.vpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.${var.project_name}-gw.id}"
}

# Create Main Security Groups and Rules
resource "aws_security_group" "frontend" {
  name        = "${var.project_name}-FE"
  description = "${var.project_name} Demo FE ${var.environmentName}"

  vpc_id = "${data.aws_vpc.selected.id}"

  tags = "${var.tags}"
}

# Allow SSH
resource "aws_security_group_rule" "bastion_ingress_22" {
  security_group_id = "${aws_security_group.frontend.id}"

  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Allow alt HTTP
resource "aws_security_group_rule" "bastion_ingress_80" {
  security_group_id = "${aws_security_group.frontend.id}"

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Allow HTTPS
resource "aws_security_group_rule" "bastion_ingress_443" {
  security_group_id = "${aws_security_group.frontend.id}"

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

# Allow it to talk to the world
resource "aws_security_group_rule" "bastion_egress" {
  security_group_id = "${aws_security_group.frontend.id}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]
}
