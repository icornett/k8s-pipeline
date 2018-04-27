variable "environmentName" {
  description = "the name of the environment being deployed"
}

variable "tags" {
  type = "map"

  default = {
    Name = "Upwork Bastion"
  }
}

variable "instance_type" {
  type    = "string"
  default = "t2.micro"
}

variable "key_name" {
  type        = "string"
  description = "the name of the AWS key pair used to authenticate to the system"
}

variable "volume_size" {
  description = "The size of the volume attached to the bastion host, smallest available is 50GB"
  type        = "string"
  default     = "50"
}

variable "aws_image" {
  description = "The AMI image to deploy for the bastion host"
  type        = "string"
  default     = "ami-38469440"

  # ami-38469440 is 11/20/2017 Amazon Linux NAT image
}

variable "vpc_id" {
  description = "The VPC ID to create the bastion host under"
}

variable "fe_subnets" {
  description = "the list of FE subnets to place the bastion host"
  type        = "list"
}

variable "fe_security_groups" {
  description = "Firewall Security Rule groups for FE"
}

variable "be_subnets" {
  description = "List of BE subnets for VPC"
  type        = "list"
}

variable "fe_cidr_blocks" {
  description = "the FE subnet CIDR blocks"
  type        = "list"
}
