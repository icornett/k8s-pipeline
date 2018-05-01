data "aws_vpc" "selected" {
  id = "${aws_vpc.vpc.id}"
}

data "aws_availability_zones" "all" {}

data "aws_eip" "public" {
  id = "${aws_eip.public_ip.id}"
}

resource "aws_vpc" "vpc" {
  cidr_block                       = "${var.cidr_block}"
  assign_generated_ipv6_cidr_block = true

  tags {
    Name = "${var.project_name} ${var.environment_name} VPC"
  }
}

resource "aws_eip" "public_ip" {
  vpc = true
}

# Create Public Subnets based on AZs
resource "aws_subnet" "public" {
  count             = "${length(data.aws_availability_zones.all.names)}"
  vpc_id            = "${data.aws_vpc.selected.id}"
  availability_zone = "${element(data.aws_availability_zones.all.names, count.index)}"
  cidr_block        = "${cidrsubnet(${aws_vpc.vpc.cidr_block}, 8, count.index + 1)}"
  ipv6_cidr_block   = "${cidrsubnet(${aws_vpc.vpc.ipv6_cidr_block}, 8, count.index + 1)}"

  tags {
    Name = "${var.project_name} ${var.environment_name} main subnet"
  }
}

# Create Private Subnets based on AZs
resource "aws_subnet" "private" {
  count             = "${length(data.aws_availability_zones.all.names)}"
  vpc_id            = "${data.aws_vpc.selected.id}"
  availability_zone = "${element(data.aws_availability_zones.all.names, count.index)}"
  cidr_block        = "${cidrsubnet(${aws_vpc.vpc.cidr_block}, 8, count.index + 10)}"
  ipv6_cidr_block   = "${cidrsubnet(${aws_vpc.vpc.ipv6_cidr_block}, 8, count.index + 10)}"

  tags {
    Name = "${var.project_name} ${var.environment_name} private subnet"
  }
}

# Set default routes
resource "aws_route_table_association" "public" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_vpc.vpc.default_route_table.id}"
}

# Allow all IPv4 to Internet
resource "aws_route" "allow_ipv4_egress" {
  route_table_id         = "${aws_vpc.vpc.default_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.inet-gw.id}"
}

# Allow all IPv6 to Internet
resource "aws_route" "allow_ipv6_egress" {
  route_table_id              = "${aws_vpc.vpc.default_route_table.id}"
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = "${aws_internet_gateway.inet-gw.id}"
}

resource "aws_route_table" "internal" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "${var.project_name}/${var.environment_name} internal route table"
  }
}

resource "aws_route" "map_public_private_v4" {
  count = "${length(aws_subnet.public.*.id)}"
  route_table_id = "${aws_route_table.internal.id}"
  destination_cidr_block = ["${element(aws_subnet.public.*.cidr_block, count.index)}"]
}

resource "aws_route" "map_public_private_v6" {
  count = "${length(aws_subnet.public.*.id)}"
  route_table_id = "${aws_route_table.internal.id}"
  destination_cidr_block = ["${element(aws_subnet.public.*.ipv6_cidr_block, count.index)}"]
}

resource "aws_route" "map_private_public_v4" {
  count = "${length(aws_subnet.private.*.id)}"
  route_table_id = "${aws_vpc.vpc.default_route_table.id}"
  destination_cidr_block = ["${element(aws_subnet.public.*.cidr_block, count.index)}"]
}

resource "aws_route" "map_private_public_v6" {
  count = "${length(aws_subnet.private.*.id)}"
  route_table_id = "${aws_vpc.vpc.default_route_table.id}"
  destination_cidr_block = ["${element(aws_subnet.private.*.ipv6_cidr_block, count.index)}"]
}

resource "aws_security_group" "public" {
  name        = "${var.project_name}-${var.environment_name}-public"
  description = "Public Ingress Rules for Project: ${var.project_name}/${var.environment_name}"
  vpc_id      = "${data.aws_vpc.selected.id}"
}

resource "aws_security_group" "private" {
  name        = "${var.project_name}-${var.environment_name}-public"
  description = "Private Ingress Rules for Project: ${var.project_name}/${var.environment_name}"
  vpc_id      = "${data.aws_vpc.selected.id}"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.public_ip.id}"
  subnet_id     = "${aws_subnet.public.id}"
}

resource "aws_internet_gateway" "inet-gw" {
  vpc_id = "${data.aws_vpc.selected.id}"

  tags {
    Name = "${var.project_name}: ${var.environment_name} Internet GW"
  }
}
