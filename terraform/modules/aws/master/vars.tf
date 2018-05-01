
variable "minSize" {
  description = "minimum number of instances to run"
  default     = "1"
}

variable "maxSize" {
  description = "maximum number of instances to run"
  default     = "2"
}

variable "environment_name" {
  description = "name of the environment being deployed"
  default     = "dev"
}

variable "cidr_block" {
  description = "the CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "server_port" {
  description = "the port HTTPD will listen on"
  default     = "8080"
}

variable "vpc_id" {
  description = "The working VPC ID"
}

variable "nat_route_table" {
  description = "The route table ID for NAT instance"
}

variable "fe_security_group" {
  description = "The set of firewall rules to apply to the FE instances"
}

variable "fe_subnets" {
  description = "The list of subnets to be utilized by the ASG"
  type        = "list"
}