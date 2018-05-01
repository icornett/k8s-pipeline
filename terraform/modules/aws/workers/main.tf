data "aws_availability_zones" "all" {}

data "aws_ami" "amazon_hvm" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-minimal-hvm-2018*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_security_group_rule" "private_enable_ssh" {
  # Add Count here to increment ports for private ingress
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${aws_subnet.public.cidr_block}"]
  ipv6_cidr_blocks  = ["${aws_subnet.public.ipv6_cidr_block}"]
  description       = "${var.project_name}: Enable SSH ingress from public subnet to private"
  security_group_id = "${aws_security_group."${var.project_name}"-private.id}"
}

resource "aws_launch_configuration" "worker-cfg" {
  name_prefix     = "${var.project_name}-${var.environment_name}-master"
  image_id        = "${data.aws_ami.amazon_hvm.id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  security_groups = ["${var.worker_security_groups}"]
  user_data       = "${file("scripts/cloud-init.tpl")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker-group" {
  max_size         = "${var.maxSize}"
  min_size         = "${var.minSize}"
  desired_capacity = "${var.desired_capacity}"
}

resource "aws_security_group_rule" "allow_all_ipv4_from_private" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = ["${var.private_subnets}"]
}
