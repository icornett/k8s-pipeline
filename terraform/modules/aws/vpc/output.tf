output "vpc" {
  value = "${data.aws_vpc.selected.id}"
}

output "vpc_cidr_block" {
  value = "${data.aws_vpc.selected.cidr_block}"
}

output "route_table" {
  value = "${aws_vpc.vpc.default_route_table_id}"
}

output "fe_subnet" {
  value = ["${aws_subnet.subnet.*.id}"]
}

output "fe_security_group" {
  value = "${aws_security_group.frontend.id}"
}

output "fe_cidr_blocks" {
  value = ["${aws_subnet.subnet.*.cidr_block}"]
}

output "be_subnet" {
  value = ["${aws_subnet.be_subnet.*.id}"]
}
