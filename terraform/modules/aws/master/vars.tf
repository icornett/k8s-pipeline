variable "minSize" {
  description = "minimum number of instances to run"
  default     = "1"
}

variable "maxSize" {
  description = "maximum number of instances to run"
  default     = "2"
}

variable "desired_capacity" {
  description = "The desired number of master instances, defaults to 1"
  default     = 1
}

variable "environment_name" {
  description = "name of the environment being deployed"
  default     = "dev"
}

variable "instance_type" {
  description = "Type of EC2 instance to use as master"
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "The working VPC ID"
}

variable "master_sg" {
  description = "The set of firewall rules to apply to the FE instances"
}

variable "master_subnets" {
  description = "The list of master subnets to be utilized by the ASG"
  type        = "list"
}

variable "key_name" {
  type        = "string"
  description = "the name of the AWS key pair used to authenticate to the system"
}
