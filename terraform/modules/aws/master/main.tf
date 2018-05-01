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

resource "aws_security_group_rule" "public_enable_ssh" {
  count             = "${var.desired_capacity}"
  type              = "ingress"
  from_port         = "${2199 + "${count.index}"}"
  to_port           = "${2199 + "${count.index}"}"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "${var.project_name}/${var.environment_name}: Enable SSH ingress to NAT"
  security_group_id = "${var.public_sg}"
}

resource "aws_launch_configuration" "master-cfg" {
  name_prefix     = "${var.project_name}-${var.environment_name}-master"
  image_id        = "${data.aws_ami.amazon_hvm.id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.key_name}"
  security_groups = ["${var.public_sg}"]
  user_data       = "${file("${path.cwd}/scripts/cloud-init.tpl")}"
  depends_on      = ["null_resource.keygen"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "master-asg" {
  max_size             = "${var.maxSize}"
  min_size             = "${var.minSize}"
  desired_capacity     = "${var.desired_capacity}"
  name                 = "${var.project_name}-${var.environment_name}-master"
  launch_configuration = "${aws_launch_configuration.master-cfg.name}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  lifecycle {
    create_before_destroy = true
  }
}

# Create SSH secrets
resource "null_resource" "keygen" {
  # Return or create SSH keys
  provisioner "local-exec" {
    command     = "${path.module}/scripts/manage_keys.py get ${var.project_name} ${var.key_name} ${var.environment_name}"
    interpreter = ["/usr/bin/python3"]
    when        = "create"
    on_failure  = "fail"
  }

  # Setup SSH Agent for connecting to master hosts
  provisioner "local-exec" {
    command     = "${path.module}/scripts/manage_keys.py agent ${var.project_name} ${var.key_name} ${var.environment_name}"
    interpreter = ["/usr/bin/python3"]
    when        = "create"
    on_failure  = "fail"
  }

  # Delete KMS key and any associated private key
  provisioner "local-exec" {
    command     = "${path.module}/scripts/manage_keys.py delete ${var.project_name} ${var.key_name} ${var.environment_name}"
    interpreter = ["/usr/bin/python3"]
    when        = "destroy"
    on_failure  = "fail"
  }
}
