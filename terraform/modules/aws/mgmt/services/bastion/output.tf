output "nat_route_table" {
  value = "${aws_route_table.natrt.id}"
}

output "natsg" {
  value = "${aws_security_group.natsg.id}"
}

output "bastion_ip" {
  value = "${aws_eip.bastion.public_ip}"
}

output "private_key" {
  value     = "${data.aws_ssm_parameter.privatekey.value}"
  sensitive = true
}
