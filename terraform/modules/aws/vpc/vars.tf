variable "project_name" {
  type        = "string"
  description = "The name of the project being run"
}

variable "environment_name" {
  default     = "dev"
  type        = "string"
  description = "Environment being deployed"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
  type = "string"
  description = "VPC base CIDR block"
}