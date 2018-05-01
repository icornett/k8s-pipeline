variable "project_name" {
  type        = "string"
  description = "The name of the project being run"
}

variable "environment_name" {
  default     = "prod"
  type        = "string"
  description = "Environment being deployed"
}
