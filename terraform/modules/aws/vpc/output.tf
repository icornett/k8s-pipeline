output "vpc" {
  value = "${data.aws_vpc.selected.id}"
}

output "vpc_cidr_block" {
  value = "${data.aws_vpc.selected.cidr_block}"
}

output "vpc_ipv6_cidr_block" {
  value = "${data.aws_vpc.selected.ipv6_cidr_block}"
}

output "route_table" {
  value = "${aws_vpc.vpc.default_route_table_id}"
}

output "public_ip" {
  value = "${data.aws_eip.public.public_ip}"
}

output "public_subnet" {
  value = ["${aws_subnet.public.*.id}"]
}

output "public_sg" {
  value = "${aws_security_group.public_sg.id}"
}

output "inet_gw" {
  value = "${aws_internet_gateway.inet_gw.id}"
}
