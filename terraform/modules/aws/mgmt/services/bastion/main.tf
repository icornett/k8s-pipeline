data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

data "aws_availability_zones" "all" {}

data "aws_ssm_parameter" "privatekey" {
  name       = "/${var.environmentName}/${var.project_name}/bastion/sshkey"
  depends_on = ["null_resource.keygen"]
}

# Create BE Security Groups and rules
resource "aws_security_group" "natsg" {
  name        = "${var.project_name} NATSG ${var.environmentName}"
  description = "${var.project_name} NAT ${var.environmentName}"
  vpc_id      = "${var.vpc_id}"

  tags = "${var.tags}"
}

# Restrict NAT port 22 to only FE subnets
resource "aws_security_group_rule" "SSH-Inbound" {
  security_group_id = "${aws_security_group.natsg.id}"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.fe_cidr_blocks}"]
}

# Allow all egress traffic on NAT
resource "aws_security_group_rule" "all_outbound" {
  security_group_id = "${aws_security_group.natsg.id}"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
}

# Restrict port 3306 to only FE subnets
resource "aws_security_group_rule" "MySQL-Inbound" {
  security_group_id = "${aws_security_group.natsg.id}"

  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  cidr_blocks = ["${var.fe_cidr_blocks}"]
}

# Create NAT route table
resource "aws_route_table" "natrt" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.project_name}-natTable-${var.environmentName}"
  }
}

# Associate BE routes with NAT route table
resource "aws_route_table_association" "nat_assoc" {
  count          = "${length(data.aws_availability_zones.all.names)}"
  subnet_id      = "${element(var.be_subnets, count.index)}"
  route_table_id = "${aws_route_table.natrt.id}"
}

# Add NAT as gateway
resource "aws_route" "nat-out" {
  route_table_id         = "${aws_route_table.natrt.id}"
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = "${aws_instance.bastion.id}"
}

# Create Bastion host secrets
resource "null_resource" "keygen" {
  provisioner "local-exec" {
    command     = "${path.module}/scripts/manage_keys.py get ${var.project_name} ${var.key_name} ${var.environmentName}"
    interpreter = ["/usr/bin/python3"]
    when        = "create"
    on_failure  = "continue"
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/manage_keys.py agent ${var.project_name} ${var.key_name} ${var.environmentName}"
    interpreter = ["/usr/bin/python3"]
    when        = "create"
    on_failure  = "fail"
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/manage_keys.py delete ${var.project_name} ${var.key_name} ${var.environmentName}"
    interpreter = ["/usr/bin/python3"]
    when        = "destroy"
    on_failure  = "continue"
  }
}

# Create Public IP
resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}

# Create Bastion Host
resource "aws_instance" "bastion" {
  ami           = "${var.aws_image}"
  instance_type = "${var.instance_type}"

  tags = "${var.tags}"

  key_name               = "${var.key_name}"
  subnet_id              = "${element(var.fe_subnets, 0)}"
  vpc_security_group_ids = ["${var.fe_security_groups}"]
  source_dest_check      = false

  root_block_device = {
    volume_type           = "standard"
    delete_on_termination = true
    volume_size           = "${var.volume_size}"
  }

  depends_on = ["null_resource.keygen"]
}
