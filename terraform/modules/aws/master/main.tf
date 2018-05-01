data "aws_availability_zones" "all" {}

data "aws_ami" "amazon_hvm" {
    most_recent = true

    filter {
        name    = "virtualization-type"
        values  = ["hvm"]
    }

    filter {
        name = "name"
        values = ["amzn-ami-minimal-hvm-2018*"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
}